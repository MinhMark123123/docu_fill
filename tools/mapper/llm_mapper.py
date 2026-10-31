"""Local LLM fallback for fields the rule mapper leaves empty.

CPU prompt processing is the bottleneck (~50 tokens/s), so the model never
sees the whole document: for each missing key, the rows most similar to the
rows that held that key's confirmed value in past cases are retrieved, and
only those rows go into one prompt. Past confirmed values are shown as
examples, so user corrections steer the model on the next case. Every answer
must be found in the source document, otherwise it is dropped.
"""

import json
import math
import re
from collections import Counter, defaultdict
from dataclasses import dataclass

from rawdoc import RawDocument, clean, norm

ROWS_PER_KEY = 2
EXAMPLES_PER_KEY = 2
MAX_ROWS = 120


def _words(text: str) -> list[str]:
    return [w for w in (norm(t) for t in re.split(r"\s+", text)) if w and not w.isdigit()]


def _row_text(doc: RawDocument, row) -> str:
    """Row cells tagged with their column header, so the model can tell the
    comparable properties (Tài sản so sánh 1/2/3) apart."""
    parts = []
    for c in row:
        if not c.text:
            continue
        header = doc.header_of(c)
        text = c.text.replace("\n", " / ")
        parts.append(f"[{header}] {text}" if header and header != c.text else text)
    return " | ".join(parts)


def _key_words(key: str) -> list[str]:
    """%%KhoangCachTuTaiSan1DenTaiSanThamDinh%% -> khoang cach tu tai san ..."""
    parts = re.findall(r"[A-Z][a-z]*|[a-z]+", key.strip("%"))
    return [p.lower() for p in parts]


@dataclass
class LlmPrediction:
    value: str
    grounded: bool


class LlmMapper:
    def __init__(self, llm):
        self.llm = llm
        self.profiles: dict[str, Counter] = {}
        self.examples: dict[str, list[str]] = {}

    def fit(self, cases: list[tuple[RawDocument, dict[str, str]]]) -> "LlmMapper":
        profiles: dict[str, Counter] = defaultdict(Counter)
        examples: dict[str, list[str]] = defaultdict(list)
        for doc, values in cases:
            for key, value in values.items():
                target = norm(value)
                if not target:
                    continue
                if value not in examples[key]:
                    examples[key].append(value)
                value_words = set(_words(value))
                for row in doc.rows:
                    if any(target in c.key for c in row if c.text):
                        for w in set(_words(_row_text(doc, row))) - value_words:
                            profiles[key][w] += 1
                        break
        self.profiles = dict(profiles)
        # most recent confirmed values first
        self.examples = {k: v[::-1][:EXAMPLES_PER_KEY] for k, v in examples.items()}
        return self

    def _retrieve(self, doc: RawDocument, keys: list[str]) -> list[int]:
        row_words = [set(_words(_row_text(doc, row))) for row in doc.rows]
        df = Counter(w for ws in row_words for w in ws)
        n = len(doc.rows)
        picked: set[int] = set()
        for key in keys:
            profile = self.profiles.get(key) or Counter({w: 1 for w in _key_words(key)})
            total = sum(profile.values())
            scores = []
            for i, ws in enumerate(row_words):
                s = sum(profile[w] / total * math.log((n + 1) / (df[w] + 1)) for w in ws if w in profile)
                if s > 0:
                    scores.append((s, i))
            for _, i in sorted(scores, reverse=True)[:ROWS_PER_KEY]:
                picked.add(i)
        return sorted(picked)[:MAX_ROWS]

    def predict(self, doc: RawDocument, keys: list[str], descriptions: dict[str, str] | None = None):
        if not keys:
            return {}, {}
        rows = self._retrieve(doc, keys)
        excerpt = "\n".join(f"[{i}] {_row_text(doc, doc.rows[i])}" for i in rows)
        alias = {f"k{n}": key for n, key in enumerate(keys, 1)}
        lines = []
        for a, key in alias.items():
            desc = (descriptions or {}).get(key) or " ".join(_key_words(key))
            ex = "; ".join(f'"{e}"' for e in self.examples.get(key, []))
            lines.append(f"- {a}: {desc}" + (f" (ví dụ đã xác nhận: {ex})" if ex else ""))
        prompt = (
            "Bạn trích xuất dữ liệu từ hồ sơ thẩm định giá tài sản của ngân hàng.\n"
            "Dưới đây là các dòng trích từ tài liệu (ô cách nhau bằng ' | ').\n"
            "Với mỗi trường, tìm giá trị trong tài liệu và chép nguyên văn. "
            "Viết theo đúng định dạng của các ví dụ đã xác nhận. "
            "Nếu tài liệu không có thông tin, bỏ qua trường đó. Không tự suy đoán.\n\n"
            f"TÀI LIỆU:\n{excerpt}\n\nCÁC TRƯỜNG:\n" + "\n".join(lines) + "\n\nTrả về JSON."
            # Qwen3 hybrid models: skip the reasoning phase (ignored by others).
            " /no_think"
        )
        schema = {
            "type": "object",
            "properties": {a: {"type": "string"} for a in alias},
        }
        out = self.llm.create_chat_completion(
            messages=[{"role": "user", "content": prompt}],
            response_format={"type": "json_object", "schema": schema},
            temperature=0,
            max_tokens=40 * len(keys) + 50,
        )
        usage = out["usage"]
        try:
            answer = json.loads(out["choices"][0]["message"]["content"])
        except json.JSONDecodeError:
            answer = {}

        doc_norm = norm(" ".join(c.text for c in doc.cells))
        doc_digits = re.sub(r"\D", "", " ".join(c.text for c in doc.cells))
        result = {}
        for a, value in answer.items():
            key = alias.get(a)
            value = clean(str(value))
            if not key or not norm(value):
                continue
            digits = re.sub(r"\D", "", value)
            # Grounding: the text (or, for reformatted numbers/dates, the digits)
            # must exist in the source document.
            grounded = norm(value) in doc_norm or (len(digits) >= 2 and digits in doc_digits and len(digits) >= len(norm(value)) * 0.6)
            result[key] = LlmPrediction(value, grounded)
        return result, {"rows": len(rows), **usage}
