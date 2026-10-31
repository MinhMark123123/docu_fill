"""Leave-one-out evaluation of the rule mapper against Gemini.

For every case (one export with Word/Excel sources), rules are learned from
all other cases and applied to this one. Predictions and Gemini's output are
both compared with the values the user finally exported.

Usage:
  python -I -X utf8 evaluate.py <dataset.jsonl> [--out report.csv] [--min-support 2]
"""

import argparse
import csv
import json
import re
import sys
from collections import Counter
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from learner import Mapper, near_value, same_value  # noqa: E402
from rawdoc import RawDocument  # noqa: E402

# Image paths are not text values.
SKIP_KEY = re.compile(r"HinhAnh", re.I)


def load_cases(path: str):
    cases = []
    for line in Path(path).read_text(encoding="utf-8").splitlines():
        pair = json.loads(line)
        texts = [s for s in pair["sources"] if s["mode"] == "text" and s.get("rawText")]
        if not texts:
            continue
        gemini: dict[str, str] = {}
        for source in texts:  # the app applies results in import order
            for key, value in (source.get("geminiOutput") or {}).items():
                if str(value or "").strip():
                    gemini[key] = str(value)
        values = {
            k: v for k, v in pair["finalValues"].items() if v and not SKIP_KEY.search(k)
        }
        doc = RawDocument("\n".join(s["rawText"] for s in texts))
        cases.append({"id": f"{pair['machine']}#{pair['historyId']}", "doc": doc, "values": values, "gemini": gemini})
    return cases


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("dataset")
    ap.add_argument("--out", default="out/report.csv")
    ap.add_argument("--min-support", type=int, default=2)
    ap.add_argument("--auto", type=float, default=0.9, help="confidence for auto-accept")
    args = ap.parse_args()

    cases = load_cases(args.dataset)
    print(f"cases with Word/Excel text: {len(cases)}")

    rows = []
    for i, case in enumerate(cases):
        train = [(c["doc"], c["values"]) for j, c in enumerate(cases) if j != i]
        predictions = Mapper(args.min_support).fit(train).predict(case["doc"])
        for key, gold in case["values"].items():
            pred = predictions.get(key)
            rows.append(
                {
                    "case": case["id"],
                    "key": key,
                    "gold": gold,
                    "rule_value": pred.value if pred else "",
                    "rule_conf": round(pred.confidence, 3) if pred else 0,
                    "rule_ok": same_value(pred.value, gold) if pred else False,
                    "rule_near": near_value(pred.value, gold) if pred else False,
                    "gemini_value": case["gemini"].get(key, ""),
                    "gemini_ok": same_value(case["gemini"].get(key), gold),
                    "gemini_near": near_value(case["gemini"].get(key), gold),
                }
            )
        print(f"  {i + 1}/{len(cases)} {case['id']}", flush=True)

    n = len(rows)
    rule_ok = sum(r["rule_ok"] for r in rows)
    gemini_ok = sum(r["gemini_ok"] for r in rows)
    either = sum(r["rule_ok"] or r["gemini_ok"] for r in rows)
    auto = [r for r in rows if r["rule_conf"] >= args.auto]
    auto_ok = sum(r["rule_ok"] for r in auto)
    filled = [r for r in rows if r["rule_value"]]

    print(f"\nfield values (non-empty, confirmed): {n}")
    print(f"  Gemini correct      : {gemini_ok / n:.1%}")
    print(f"  Rules correct       : {rule_ok / n:.1%}  (filled {len(filled) / n:.1%}, "
          f"precision when filled {sum(r['rule_ok'] for r in filled) / max(len(filled), 1):.1%})")
    print(f"  Rules auto (conf>={args.auto}): coverage {len(auto) / n:.1%}, "
          f"precision {auto_ok / max(len(auto), 1):.1%}")
    print(f"  Rules or Gemini     : {either / n:.1%}")
    print(f"  Near (small edit)   : Gemini {sum(r['gemini_near'] for r in rows) / n:.1%}, "
          f"Rules {sum(r['rule_near'] for r in rows) / n:.1%}")

    per_key = Counter()
    per_key_ok = Counter()
    for r in rows:
        per_key[r["key"]] += 1
        per_key_ok[r["key"]] += r["rule_ok"]
    good = sum(1 for k in per_key if per_key_ok[k] / per_key[k] >= 0.9)
    print(f"  keys with rule accuracy >= 90%: {good}/{len(per_key)}")

    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    with out.open("w", newline="", encoding="utf-8-sig") as f:
        writer = csv.DictWriter(f, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)
    print(f"details -> {out}")


if __name__ == "__main__":
    main()
