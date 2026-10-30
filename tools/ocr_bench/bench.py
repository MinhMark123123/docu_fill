"""OCR benchmark on real PDFs, scored against values the user exported.

No hand-typed ground truth is needed: for each case we know the final field
values of the matching export history, so we measure whether each value can be
found in the OCR text ("value recall"). That is what the mapping step needs.

Usage:
  python -I bench.py --pdf-dir <dir> --cases data/cases.json \
      --histories <export_histories.json> --logs <api_logs.jsonl> \
      [--engines tess_best,det_vietocr_tf] [--dpi 200] [--out out]
"""

import argparse
import csv
import glob
import json
import os
import re
import sys
import time
import unicodedata
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
import engines  # noqa: E402  (installs netguard)

from rapidfuzz import fuzz  # noqa: E402

# Keys whose values are image paths or app-side computations, never PDF text.
SKIP_KEY = re.compile(r"HinhAnh|PhanTram|DieuChinh", re.I)


def norm_exact(s: str) -> str:
    return re.sub(r"\s+", "", unicodedata.normalize("NFC", s).lower())


def norm_loose(s: str) -> str:
    s = unicodedata.normalize("NFD", s.lower()).replace("đ", "d")
    s = "".join(c for c in s if unicodedata.category(c) != "Mn")
    return re.sub(r"[^0-9a-z]", "", s)


def find_pdf(pdf_dir: str, prefix: str) -> str:
    prefix = unicodedata.normalize("NFC", prefix)
    for path in glob.glob(os.path.join(pdf_dir, "*.pdf")):
        if unicodedata.normalize("NFC", os.path.basename(path)).startswith(prefix):
            return path
    raise FileNotFoundError(prefix)


def run_ocr(engine_name: str, dpi: int, pdf: str, cache: Path) -> dict:
    if cache.exists():
        return json.loads(cache.read_text(encoding="utf-8"))
    engine = engines.ENGINES[engine_name]()
    pages = []
    for index, img in engines.render_pages(pdf, dpi):
        start = time.perf_counter()
        lines = engine(img)
        pages.append(
            {
                "page": index,
                "seconds": time.perf_counter() - start,
                "lines": [l.__dict__ for l in lines],
            }
        )
        print(f"  {engine_name} {dpi}dpi page {index + 1}: {pages[-1]['seconds']:.1f}s", flush=True)
    result = {"engine": engine_name, "dpi": dpi, "pdf": os.path.basename(pdf), "pages": pages}
    cache.parent.mkdir(parents=True, exist_ok=True)
    cache.write_text(json.dumps(result, ensure_ascii=False), encoding="utf-8")
    return result


def gold_values(history: dict) -> dict[str, str]:
    values = {}
    for key, entry in history["fieldValues"].items():
        value = (entry or {}).get("value") or ""
        if SKIP_KEY.search(key) or len(norm_loose(value)) < 3:
            continue
        values[key] = value
    return values


def is_numeric(value: str) -> bool:
    """Numbers, dates, phone/ID numbers: these must be read exactly."""
    alnum = norm_loose(value)
    digits = sum(c.isdigit() for c in alnum)
    return digits >= 2 and digits / len(alnum) >= 0.5


def match(value: str, text_exact: str, text_loose: str) -> str:
    if norm_exact(value) in text_exact:
        return "exact"
    loose = norm_loose(value)
    if loose in text_loose:
        return "loose"
    # A number that is "almost right" is wrong, so no fuzzy match for numbers.
    if is_numeric(value):
        return "miss"
    if len(loose) >= 6 and fuzz.partial_ratio(loose, text_loose) >= 90:
        return "fuzzy"
    return "miss"


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--pdf-dir", required=True)
    ap.add_argument("--cases", required=True)
    ap.add_argument("--histories", required=True)
    ap.add_argument("--logs", required=True)
    ap.add_argument("--engines", default=",".join(engines.ENGINES))
    ap.add_argument("--dpi", default="200")
    ap.add_argument("--out", default="out")
    args = ap.parse_args()

    out = Path(args.out)
    cases = json.loads(Path(args.cases).read_text(encoding="utf-8"))
    histories = {
        h["id"]: h
        for h in json.loads(Path(args.histories).read_text(encoding="utf-8"))
    }
    gemini_by_file: dict[str, dict] = {}
    for row in Path(args.logs).read_text(encoding="utf-8").splitlines():
        log = json.loads(row)
        if log["mode"] == "file" and log["response"]:
            gemini_by_file[unicodedata.normalize("NFC", log["fileName"])] = log["response"]

    details, summary = [], []
    for engine_name in args.engines.split(","):
        for dpi in map(int, args.dpi.split(",")):
            totals = {"all": [0, 0, 0], "pdf": [0, 0, 0], "num": [0, 0, 0]}  # exact, any, count
            seconds, pages = 0.0, 0
            for case in cases:
                pdf = find_pdf(args.pdf_dir, case["pdf_prefix"])
                pdf_name = unicodedata.normalize("NFC", os.path.basename(pdf))
                print(f"{engine_name} @ {dpi}dpi :: {pdf_name}", flush=True)
                cache = out / "raw" / f"{engine_name}_{dpi}" / f"{case['id']}.json"
                result = run_ocr(engine_name, dpi, pdf, cache)
                seconds += sum(p["seconds"] for p in result["pages"])
                pages += len(result["pages"])

                text = "\n".join(l["text"] for p in result["pages"] for l in p["lines"])
                text_exact, text_loose = norm_exact(text), norm_loose(text)
                gemini = gemini_by_file.get(pdf_name, {})
                for key, value in gold_values(histories[case["history_id"]]).items():
                    level = match(value, text_exact, text_loose)
                    # Gemini read this exact value from the PDF -> surely on the page.
                    confirmed = norm_loose(str(gemini.get(key, ""))) == norm_loose(value)
                    numeric = is_numeric(value)
                    buckets = ["all"] + ["pdf"] * confirmed + ["num"] * (confirmed and numeric)
                    for bucket in buckets:
                        totals[bucket][0] += level == "exact"
                        totals[bucket][1] += level != "miss"
                        totals[bucket][2] += 1
                    details.append(
                        {
                            "engine": engine_name, "dpi": dpi, "case": case["id"],
                            "key": key, "gold": value, "pdf_confirmed": confirmed, "numeric": numeric,
                            "match": level,
                        }
                    )
            row = {"engine": engine_name, "dpi": dpi, "sec_per_page": round(seconds / max(pages, 1), 2)}
            for bucket, (exact, found, count) in totals.items():
                row[f"{bucket}_n"] = count
                row[f"{bucket}_exact"] = round(exact / max(count, 1), 3)
                row[f"{bucket}_found"] = round(found / max(count, 1), 3)
            summary.append(row)
            print(json.dumps(row), flush=True)

    out.mkdir(parents=True, exist_ok=True)
    with open(out / "details.csv", "w", newline="", encoding="utf-8-sig") as f:
        writer = csv.DictWriter(f, fieldnames=list(details[0]))
        writer.writeheader()
        writer.writerows(details)
    with open(out / "summary.csv", "w", newline="", encoding="utf-8-sig") as f:
        writer = csv.DictWriter(f, fieldnames=list(summary[0]))
        writer.writeheader()
        writer.writerows(summary)
    print("\nengine               dpi  s/page  all(n) exact found  pdf(n) exact found  num(n) found")
    for r in summary:
        print(
            f"{r['engine']:<20} {r['dpi']:>3} {r['sec_per_page']:>7} "
            f"{r['all_n']:>6} {r['all_exact']:>5} {r['all_found']:>5} "
            f"{r['pdf_n']:>7} {r['pdf_exact']:>5} {r['pdf_found']:>5}"
            f"  {r['num_n']:>6} {r['num_found']:>5}"
        )


if __name__ == "__main__":
    main()
