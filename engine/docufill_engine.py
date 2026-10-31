"""DocuFill offline engine: PDF OCR and field mapping without any network.

The Flutter app runs this as a child process, one command per call:

  docufill_engine ocr  --input <file.pdf> --output <result.json>
  docufill_engine map  --request <request.json> --output <result.json> [--llm]
  docufill_engine info --output <result.json>

Progress goes to stderr as lines "PROGRESS {json}"; errors as "ERROR <text>"
with a non-zero exit code. Results are JSON files (UTF-8), never stdout, so
console encoding does not matter.

map request:
  {"text": "<source text, rows of ' | ' cells>",
   "fields": {"%%Key%%": "description", ...},
   "cases": [{"text": "...", "values": {"%%Key%%": "confirmed value"}}],
   "case_files": ["<dataset.jsonl of tools/data_export or export_histories.json of the in-app export>", ...]}
map result:
  {"values": {"%%Key%%": {"value", "source": "rule"|"llm", "confidence", "review"}},
   "stats": {...}}
"""

import argparse
import hashlib
import json
import os
import sys
import time
import traceback
from dataclasses import asdict
from pathlib import Path

# Windowed build started without pipes (e.g. double-clicked): no stderr.
if sys.stderr is None:
    sys.stderr = open(os.devnull, "w")
if sys.stdout is None:
    sys.stdout = open(os.devnull, "w")

# Frozen build: models sit next to the executable. Source checkout: reuse the
# dev tools and their downloaded models.
if getattr(sys, "frozen", False):
    MODELS = Path(sys.executable).parent / "models"
else:
    TOOLS = Path(__file__).resolve().parent.parent / "tools"
    sys.path[:0] = [str(TOOLS / "ocr_bench"), str(TOOLS / "mapper")]
    MODELS = TOOLS / "ocr_bench" / "models"

import netguard  # noqa: E402,F401  (blocks the network before anything else loads)

# Part of the rule cache key: bump it with every change to the mapper code
# (tools/mapper), so rules learned by an older version are not reused.
VERSION = "0.1.0"
LLM_FILE = "llm/Qwen_Qwen3-4B-Instruct-2507-Q4_K_M.gguf"
OCR_DPI = 200
AUTO_CONFIDENCE = 0.9  # rule values at or above this are not flagged for review
MASK = "⁇"  # OCR number the two recognizers disagree on


def progress(stage: str, done: int = 0, total: int = 0) -> None:
    print("PROGRESS " + json.dumps({"stage": stage, "done": done, "total": total}),
          file=sys.stderr, flush=True)


def write_json(path: str, data) -> None:
    tmp = Path(path).with_suffix(".part")
    tmp.write_text(json.dumps(data, ensure_ascii=False), encoding="utf-8")
    tmp.replace(path)


# --- OCR ---------------------------------------------------------------------

def cmd_ocr(args) -> dict:
    import engines
    import layout

    engines.MODELS = MODELS
    progress("load_ocr")
    engine = engines.HybridEngine()
    import pymupdf

    total = len(pymupdf.open(args.input))
    pages, conflicts, start = [], 0, time.perf_counter()
    for index, img in engines.render_pages(args.input, OCR_DPI):
        progress("ocr_page", index, total)
        lines = engine(img)
        conflicts += sum(1 for l in lines if l.flag == "digits_conflict")
        # Mapping reads the safe text: disputed numbers stay masked, so a value
        # built from them is flagged instead of trusted.
        page_lines = [{"text": l.safe or l.text, "box": l.box} for l in lines]
        pages.append(layout.page_text(page_lines, img))
    progress("ocr_page", total, total)
    return {
        "text": "\n".join(pages),
        "method": "offline_ocr_hybrid",
        "pages": total,
        "digit_conflicts": conflicts,
        "seconds": round(time.perf_counter() - start, 1),
    }


# --- Mapping -----------------------------------------------------------------

def _load_cases(request: dict) -> list[tuple[str, dict[str, str]]]:
    cases = [(c["text"], c["values"]) for c in request.get("cases", []) if c.get("text")]
    for path in request.get("case_files", []):
        if not Path(path).exists():
            continue
        if path.endswith(".json"):  # export_histories.json of the in-app data export
            for history in json.loads(Path(path).read_text(encoding="utf-8")):
                text = "\n".join(s["text"] for s in history.get("sources", []) if s.get("text"))
                if text:
                    values = {
                        k: e.get("value")
                        for group in ("fieldValues", "singleLineValues")
                        for k, e in history.get(group, {}).items()
                    }
                    cases.append((text, values))
            continue
        for line in Path(path).read_text(encoding="utf-8").splitlines():
            if not line.strip():
                continue
            pair = json.loads(line)
            if "finalValues" in pair:  # tools/data_export dataset.jsonl
                texts = [s["rawText"] for s in pair["sources"] if s["mode"] == "text" and s.get("rawText")]
                if texts:
                    cases.append(("\n".join(texts), pair["finalValues"]))
            elif pair.get("text"):
                cases.append((pair["text"], pair["values"]))
    return [(t, {k: v for k, v in vals.items() if v}) for t, vals in cases]


def _cache_dir() -> Path:
    base = os.environ.get("LOCALAPPDATA") or str(Path.home())
    path = Path(base) / "DocuFill" / "engine_cache"
    path.mkdir(parents=True, exist_ok=True)
    return path


def _fit_rules(cases, docs):
    """Rule set for these cases, cached by content hash: fitting takes tens of
    seconds, and the cases only change after an export."""
    from learner import Mapper, Rule

    digest = hashlib.sha256(
        json.dumps([VERSION, cases], ensure_ascii=False, sort_keys=True).encode()
    ).hexdigest()[:32]
    cache = _cache_dir() / f"rules_{digest}.json"
    mapper = Mapper()
    if cache.exists():
        data = json.loads(cache.read_text(encoding="utf-8"))
        mapper.rules = {
            key: {Rule(**r): stats for r, stats in items} for key, items in data.items()
        }
        return mapper
    progress("learn_rules", 0, len(cases))
    mapper.fit(list(zip(docs, (v for _, v in cases))))
    data = {key: [[asdict(r), s] for r, s in rules.items()] for key, rules in mapper.rules.items()}
    write_json(str(cache), data)
    for old in cache.parent.glob("rules_*.json"):  # keep only the current set
        if old != cache:
            old.unlink(missing_ok=True)
    return mapper


def cmd_map(args) -> dict:
    from llm_mapper import LlmMapper
    from rawdoc import RawDocument

    request = json.loads(Path(args.request).read_text(encoding="utf-8"))
    fields: dict[str, str] = request["fields"]
    cases = _load_cases(request)
    docs = [RawDocument(t) for t, _ in cases]
    doc = RawDocument(request["text"])

    values, stats = {}, {"cases": len(cases)}
    if cases:
        mapper = _fit_rules(cases, docs)
        progress("apply_rules")
        for key, pred in mapper.predict(doc).items():
            if key in fields:
                values[key] = {
                    "value": pred.value,
                    "source": "rule",
                    "confidence": round(pred.confidence, 3),
                    "review": pred.confidence < AUTO_CONFIDENCE or MASK in pred.value,
                }
    stats["rules"] = len(values)

    missing = [k for k in fields if k not in values]
    if args.llm and missing:
        from llama_cpp import Llama

        progress("load_llm")
        threads = max(1, (os.cpu_count() or 2) * 3 // 4)
        llm = Llama(model_path=str(MODELS / LLM_FILE), n_ctx=8192, n_threads=threads, verbose=False)
        progress("llm", 0, len(missing))
        preds, usage = LlmMapper(llm).fit(list(zip(docs, (v for _, v in cases)))).predict(
            doc, missing, fields
        )
        for key, pred in preds.items():
            if pred.grounded:
                values[key] = {"value": pred.value, "source": "llm", "confidence": 0.0, "review": True}
        stats["llm"] = sum(1 for v in values.values() if v["source"] == "llm")
        stats["llm_usage"] = usage
    return {"values": values, "stats": stats}


def cmd_info(args) -> dict:
    return {
        "version": VERSION,
        "ocr_models": (MODELS / "PP-OCRv6_det_small.onnx").exists()
        and (MODELS / "vietocr" / "vgg_seq2seq.pth").exists(),
        "llm_model": (MODELS / LLM_FILE).exists(),
    }


def main() -> int:
    ap = argparse.ArgumentParser(prog="docufill_engine")
    sub = ap.add_subparsers(dest="command", required=True)
    p = sub.add_parser("ocr")
    p.add_argument("--input", required=True)
    p.add_argument("--output", required=True)
    p = sub.add_parser("map")
    p.add_argument("--request", required=True)
    p.add_argument("--output", required=True)
    p.add_argument("--llm", action="store_true", help="local LLM for keys the rules leave empty")
    p = sub.add_parser("info")
    p.add_argument("--output", required=True)
    args = ap.parse_args()

    try:
        result = {"ocr": cmd_ocr, "map": cmd_map, "info": cmd_info}[args.command](args)
    except Exception as e:  # reported to the app, which shows the message
        traceback.print_exc(file=sys.stderr)
        print(f"ERROR {type(e).__name__}: {e}", file=sys.stderr, flush=True)
        return 1
    write_json(args.output, result)
    return 0


if __name__ == "__main__":
    sys.exit(main())
