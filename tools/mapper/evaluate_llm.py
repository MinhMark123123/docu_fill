"""Leave-one-out: rules first, local LLM for the keys the rules leave empty.

Usage:
  python -I -X utf8 evaluate_llm.py <dataset.jsonl> --model <file.gguf> [--cases 10]
"""

import argparse
import csv
import os
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
sys.path.insert(0, str(Path(__file__).parent.parent / "ocr_bench"))
import netguard  # noqa: E402,F401  (no network for the model process)

from evaluate import load_cases  # noqa: E402
from learner import Mapper, near_value, same_value  # noqa: E402
from llm_mapper import LlmMapper  # noqa: E402


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("dataset")
    ap.add_argument("--model", required=True)
    ap.add_argument("--cases", type=int, default=10, help="evaluate the first N cases")
    ap.add_argument("--threads", type=int, default=max(1, (os.cpu_count() or 2) * 3 // 4))
    ap.add_argument("--out", default="out/report_llm.csv")
    args = ap.parse_args()

    from llama_cpp import Llama

    llm = Llama(model_path=args.model, n_ctx=16384, n_threads=args.threads, verbose=False)
    cases = load_cases(args.dataset)
    rows, timings = [], []
    for i, case in enumerate(cases[: args.cases]):
        train = [(c["doc"], c["values"]) for j, c in enumerate(cases) if j != i]
        rules = Mapper().fit(train).predict(case["doc"])
        missing = [k for k in case["values"] if k not in rules]
        start = time.perf_counter()
        llm_preds, usage = LlmMapper(llm).fit(train).predict(case["doc"], missing)
        seconds = time.perf_counter() - start
        timings.append(seconds)
        for key, gold in case["values"].items():
            rule = rules.get(key)
            lp = llm_preds.get(key)
            value, source = "", ""
            if rule:
                value, source = rule.value, "rule"
            elif lp and lp.grounded:
                value, source = lp.value, "llm"
            rows.append(
                {
                    "case": case["id"], "key": key, "gold": gold, "value": value, "source": source,
                    "ok": same_value(value, gold) if value else False,
                    "near": near_value(value, gold),
                    "llm_raw": lp.raw if lp else "", "llm_grounded": lp.grounded if lp else "",
                    "gemini_ok": same_value(case["gemini"].get(key), gold),
                    "gemini_near": near_value(case["gemini"].get(key), gold),
                }
            )
        print(f"{i + 1}/{args.cases} {case['id']}: {seconds:.0f}s, missing={len(missing)}, {usage}", flush=True)

    n = len(rows)
    def pct(pred):
        return f"{sum(1 for r in rows if pred(r)) / n:.1%}"
    filled = [r for r in rows if r["value"]]
    llm_rows = [r for r in rows if r["source"] == "llm"]
    print(f"\nvalues: {n}  (cases {args.cases})")
    print(f"  Gemini correct        : {pct(lambda r: r['gemini_ok'])}")
    print(f"  Rules correct         : {pct(lambda r: r['source'] == 'rule' and r['ok'])}")
    print(f"  Rules + LLM correct   : {pct(lambda r: r['ok'])}  (filled {len(filled) / n:.1%}, "
          f"precision {sum(r['ok'] for r in filled) / max(len(filled), 1):.1%})")
    print(f"  LLM part              : filled {len(llm_rows)}, precision "
          f"{sum(r['ok'] for r in llm_rows) / max(len(llm_rows), 1):.1%}, "
          f"dropped ungrounded {sum(1 for r in rows if r['llm_raw'] and r['llm_grounded'] is False)}")
    print(f"  Near (small edit)     : Gemini {pct(lambda r: r['gemini_near'])}, "
          f"Rules + LLM {pct(lambda r: r['near'])}")
    print(f"  LLM seconds per case  : avg {sum(timings) / len(timings):.0f}, max {max(timings):.0f}")

    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    with out.open("w", newline="", encoding="utf-8-sig") as f:
        writer = csv.DictWriter(f, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)


if __name__ == "__main__":
    main()
