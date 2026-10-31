"""Local LLM fallback for fields the rule mapper leaves empty.

CPU prompt processing is the bottleneck (~50 tokens/s), so the model never
sees the whole document: for each missing key, the rows most similar to the
rows that held that key's confirmed value in past cases are retrieved, and
only those rows go into the prompt. Past confirmed values are shown as
examples, so user corrections steer the model on the next case.

Three safeguards against the errors seen in evaluation:
- Keys of one comparable property (...TaiSan2, NguoiBan2) are asked in their
  own prompt that only shows that property's column of the comparison table,
  so values cannot be taken from a neighbouring column.
- Every number in an answer must be a number in the cells the model was
  shown, and its text must occur there, otherwise the answer is dropped.
- Answers are brought to the format of the confirmed values ("khoảng 650m"
  -> "650m" when no confirmed value has a leading word).
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
MIN_FORMAT_EXAMPLES = 2
MAX_STRIPPED_WORDS = 3
MAX_UNIT_LEN = 4

KEY_PROPERTY = re.compile(r"(?:TaiSan|NguoiBan)([1-9])")
NUMBER = re.compile(r"\d+(?:[.,]\d+)*")


def _words(text: str) -> list[str]:
    return [w for w in (norm(t) for t in re.split(r"\s+", text)) if w and not w.isdigit()]


def _key_property(key: str) -> str | None:
    """Property a key belongs to: "1".."9" for comparables, "0" for the
    appraised property, None for general fields."""
    m = KEY_PROPERTY.search(key)
    if m:
        return m.group(1)
    return "0" if "TaiSanThamDinh" in key else None


def _visible_cells(doc: RawDocument, row, prop: str | None):
    """Cells of a row the model may see. Inside a comparison table, a prompt
    for one property sees the label columns and that property's column only."""
    cols = doc.property_columns.get(row[0].row) if row else None
    for c in row:
        if not c.text:
            continue
        if cols and prop is not None and c.col >= min(cols) and doc.property_of(c) != prop:
            continue
        yield c


def _row_text(doc: RawDocument, row, prop: str | None = None) -> str:
    """Row cells tagged with their column header, so the model can tell the
    comparable properties (Tài sản so sánh 1/2/3) apart."""
    cols = doc.property_columns.get(row[0].row) if row else None
    parts = []
    for c in _visible_cells(doc, row, prop):
        header = cols[c.col].text if cols and c.col in cols else ("" if cols else doc.header_of(c))
        text = c.text.replace("\n", " / ")
        parts.append(f"[{header}] {text}" if header and header != c.text else text)
    return " | ".join(parts)


def _key_words(key: str) -> list[str]:
    """%%KhoangCachTuTaiSan1DenTaiSanThamDinh%% -> khoang cach tu tai san ..."""
    parts = re.findall(r"[A-Z][a-z]*|[a-z]+", key.strip("%"))
    return [p.lower() for p in parts]


def _number_set(text: str) -> set[str]:
    """Numbers as digit strings, separators ignored:
    "1.125.000.000", "1125000000" and "1,125,000,000" are the same number."""
    return {re.sub(r"\D", "", n) for n in NUMBER.findall(text)}


def grounded(value: str, shown: list[str]) -> bool:
    """Every number of the answer is a number of a shown cell (numbers must be
    exact), and its text occurs in the shown cells."""
    nums = _number_set(value)
    if not nums <= set().union(*map(_number_set, shown)):
        return False
    if re.search(r"[^\W\d_]", value):
        return norm(value) in norm(" ".join(shown))
    return bool(nums)


def _unit(value: str) -> str | None:
    """Text after the last number ("650m" -> "m"), None without numbers."""
    m = re.search(r"\d\s*(k?m2|m²|[^\d\s][^\d]*)?\s*$", value)
    return (m.group(1) or "").strip() if m else None


def conform(value: str, examples: list[str]) -> str:
    """Bring an answer to the format shared by all confirmed values of the key."""
    if len(examples) < MIN_FORMAT_EXAMPLES or not re.search(r"\d", value):
        return value
    # Leading words: "khoảng 650m" -> "650m" when every confirmed value starts
    # with a number.
    if all(re.match(r"\d", e) for e in examples):
        lead = re.match(r"\D*", value).group()
        if lead and len(lead.split()) <= MAX_STRIPPED_WORDS:
            value = value[len(lead):]
    # Unit after the number: drop, add or replace when all confirmed values
    # agree ("50" -> "50m2", "18,8m" -> "18,8", "300m²" -> "300m2").
    units = {_unit(e) for e in examples}
    unit = _unit(value)
    if len(units) == 1 and unit is not None and len(unit) <= MAX_UNIT_LEN:
        (target,) = units
        if target is not None and len(target) <= MAX_UNIT_LEN and target != unit:
            if unit:  # every number of a range: "56,6m-56,9m" -> "56,6-56,9"
                value = re.sub(rf"(?<=\d)\s*{re.escape(unit)}(?![^\W\d_])", target, value)
            else:
                value = value.rstrip() + target
    # Decimal comma: "15.23" -> "15,23" when confirmed values write "56,6".
    if any(re.search(r"\d,\d{1,2}(?!\d)", e) for e in examples) and not any(
        re.search(r"\d\.\d{1,2}(?!\d)", e) for e in examples
    ):
        value = re.sub(r"(?<=\d)\.(?=\d{1,2}(?!\d))", ",", value)
    return value


@dataclass
class LlmPrediction:
    value: str
    grounded: bool
    raw: str = ""


class LlmMapper:
    def __init__(self, llm):
        self.llm = llm
        self.profiles: dict[str, Counter] = {}
        self.examples: dict[str, list[str]] = {}
        self.confirmed: dict[str, list[str]] = {}

    def fit(self, cases: list[tuple[RawDocument, dict[str, str]]]) -> "LlmMapper":
        profiles: dict[str, Counter] = defaultdict(Counter)
        confirmed: dict[str, list[str]] = defaultdict(list)
        for doc, values in cases:
            for key, value in values.items():
                target = norm(value)
                if not target:
                    continue
                confirmed[key].append(value)
                prop = _key_property(key)
                value_words = set(_words(value))
                for row in doc.rows:
                    if any(target in c.key for c in _visible_cells(doc, row, prop)):
                        for w in set(_words(_row_text(doc, row, prop))) - value_words:
                            profiles[key][w] += 1
                        break
        self.profiles = dict(profiles)
        self.confirmed = dict(confirmed)
        # most recent confirmed values first, without repeats
        self.examples = {
            k: list(dict.fromkeys(v[::-1]))[:EXAMPLES_PER_KEY] for k, v in confirmed.items()
        }
        return self

    def _retrieve(self, doc: RawDocument, keys: list[str], prop: str | None) -> list[int]:
        row_words = [set(_words(_row_text(doc, row, prop))) for row in doc.rows]
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

    def _ask(self, doc: RawDocument, keys: list[str], prop: str | None, descriptions):
        rows = self._retrieve(doc, keys, prop)
        if not rows:
            return {}, {"rows": 0}
        excerpt = "\n".join(f"[{i}] {_row_text(doc, doc.rows[i], prop)}" for i in rows)
        shown = [c.text for i in rows for c in _visible_cells(doc, doc.rows[i], prop)]
        alias = {f"k{n}": key for n, key in enumerate(keys, 1)}
        lines = []
        for a, key in alias.items():
            desc = (descriptions or {}).get(key) or " ".join(_key_words(key))
            ex = "; ".join(f'"{e}"' for e in self.examples.get(key, []))
            lines.append(f"- {a}: {desc}" + (f" (ví dụ đã xác nhận: {ex})" if ex else ""))
        scope = ""
        if prop == "0":
            scope = "Các trường dưới đây đều nói về TÀI SẢN THẨM ĐỊNH.\n"
        elif prop:
            scope = f"Các trường dưới đây đều nói về TÀI SẢN SO SÁNH {prop}.\n"
        # Fixed instructions first: llama.cpp reuses the cached prefix between calls.
        prompt = (
            "Bạn trích xuất dữ liệu từ hồ sơ thẩm định giá tài sản của ngân hàng.\n"
            "Với mỗi trường, tìm giá trị trong tài liệu và chép nguyên văn. "
            "Viết theo đúng định dạng của các ví dụ đã xác nhận. "
            "Nếu tài liệu không có thông tin, bỏ qua trường đó. Không tự suy đoán.\n"
            "Tài liệu gồm các dòng trích, ô cách nhau bằng ' | '.\n\n"
            f"TÀI LIỆU:\n{excerpt}\n\n{scope}CÁC TRƯỜNG:\n" + "\n".join(lines) + "\n\nTrả về JSON."
            # Qwen3 hybrid models: skip the reasoning phase (ignored by others).
            " /no_think"
        )
        schema = {"type": "object", "properties": {a: {"type": "string"} for a in alias}}
        out = self.llm.create_chat_completion(
            messages=[{"role": "user", "content": prompt}],
            response_format={"type": "json_object", "schema": schema},
            temperature=0,
            max_tokens=40 * len(keys) + 50,
        )
        try:
            answer = json.loads(out["choices"][0]["message"]["content"])
        except json.JSONDecodeError:
            answer = {}

        result = {}
        for a, raw in answer.items():
            key = alias.get(a)
            raw = clean(str(raw))
            if not key or not norm(raw):
                continue
            ok = grounded(raw, shown)
            value = conform(raw, self.confirmed.get(key, [])) if ok else raw
            result[key] = LlmPrediction(value, ok, raw)
        return result, {"rows": len(rows), **out["usage"]}

    def predict(self, doc: RawDocument, keys: list[str], descriptions: dict[str, str] | None = None):
        groups: dict[str | None, list[str]] = defaultdict(list)
        for key in keys:
            groups[_key_property(key)].append(key)
        result, stats = {}, Counter()
        for prop, group in groups.items():
            preds, usage = self._ask(doc, group, prop, descriptions)
            result.update(preds)
            stats.update({k: v for k, v in usage.items() if isinstance(v, int)})
        stats["prompts"] = len(groups)
        return result, dict(stats)
