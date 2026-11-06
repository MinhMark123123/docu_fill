"""Leave-one-out on the app's export history (export_histories.json), against
what the app really proposed for each case when it was imported.

Usage:
  python -I -X utf8 evaluate_recent.py <export_histories.json> [--gold id=gold.json]
      [--dataset dataset.jsonl] [--out report.csv] [--no-domain]
      [--llm model.gguf --cases 188,186]

Adjustment rates count as equal when they are the same number ("0.05", "5%").

Exports the user did not review (see reviewed.py) are not used for learning or as
a reference; --gold gives hand-checked values for one of them.
"""

import argparse
import csv
import json
import sys
from collections import Counter
from datetime import date, datetime
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from domain import branch_values, extract, percent, tidy  # noqa: E402
from learner import Mapper, same_value  # noqa: E402
from rawdoc import RawDocument  # noqa: E402
from reviewed import is_reviewed  # noqa: E402


def values_of(history: dict) -> dict[str, str]:
    return {
        k: e.get("value") or ""
        for group in ("fieldValues", "singleLineValues")
        for k, e in history.get(group, {}).items()
    }


def predict(doc, mapper, cases, today, use_domain=True, ocr=False) -> tuple[dict[str, str], set[str]]:
    predicted = {k: p.value for k, p in mapper.predict(doc).items()}
    if not use_domain:
        return predicted, set()
    found = extract(doc, today, ocr=ocr)
    predicted.update(found.values)
    for key, value in branch_values(cases, predicted.get("%%TenChiNhanh%%")).items():
        predicted.setdefault(key, value)
    for key in found.empty:
        predicted.pop(key, None)
    return predicted, found.empty


def same(key: str, got: str, want: str) -> bool:
    if same_value(got, want):
        return True
    if "PhanTram" in key:
        def rate(v):
            return v.strip() if v.strip().endswith("%") else percent(v)
        return rate(got) is not None and rate(got) == rate(want)
    return False


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("histories")
    ap.add_argument("--gold", action="append", default=[], help="<history id>=<json file>")
    ap.add_argument("--out", default="out/report_recent.csv")
    ap.add_argument("--no-domain", action="store_true")
    ap.add_argument("--dataset", help="older cases of tools/data_export, for learning only")
    ap.add_argument("--llm", help="GGUF model: also ask it for keys still empty")
    ap.add_argument("--cases", help="only these history ids, comma separated")
    args = ap.parse_args()

    histories = json.loads(Path(args.histories).read_text(encoding="utf-8"))
    histories = [h for h in histories if any(s.get("text") for s in h.get("sources", []))]
    histories.sort(key=lambda h: h["createdAt"], reverse=True)
    gold_files = dict(g.split("=", 1) for g in args.gold)
    only = set(args.cases.split(",")) if args.cases else None

    older = []
    if args.dataset:
        for line in Path(args.dataset).read_text(encoding="utf-8").splitlines():
            pair = json.loads(line)
            texts = [s["rawText"] for s in pair["sources"] if s["mode"] == "text" and s.get("rawText")]
            if texts:
                older.append(("\n".join(texts), {k: v for k, v in pair["finalValues"].items() if v}))
    older_docs = [RawDocument(t) for t, _ in older]
    doc_of = {
        h["id"]: RawDocument("\n".join(s["text"] for s in h["sources"] if s.get("text"))) for h in histories
    }
    llm = None
    if args.llm:
        from llama_cpp import Llama

        llm = Llama(model_path=args.llm, n_ctx=8192, n_threads=8, verbose=False)

    rows, totals = [], Counter()
    for target in histories:
        tid = str(target["id"])
        if only and tid not in only:
            continue
        reviewed = is_reviewed(target)
        if not reviewed and tid not in gold_files:
            print(f"#{tid}: not reviewed, skipped as a reference")
            continue
        gold = (
            json.loads(Path(gold_files[tid]).read_text(encoding="utf-8"))
            if tid in gold_files else values_of(target)
        )
        train = [h for h in histories if h is not target and is_reviewed(h)]
        pairs = [("", values_of(h)) for h in train] + older
        docs = [doc_of[h["id"]] for h in train] + older_docs
        learning = [{k: v for k, v in vals.items() if v} for _, vals in pairs]
        mapper = Mapper().fit(list(zip(docs, learning)))

        doc = doc_of[target["id"]]
        ocr = any(s.get("sourceType") == "pdf" for s in target["sources"])
        today = datetime.fromisoformat(target["createdAt"]).date() if target.get("createdAt") else date.today()
        new, blanked = predict(doc, mapper, pairs, today, not args.no_domain, ocr)
        if llm:
            from llm_mapper import LlmMapper
            from shapes import plausible

            asker = LlmMapper(llm, ocr=ocr).fit(list(zip(docs, learning)))
            missing = [k for k in gold if k not in new and k not in blanked and k in asker.confirmed]
            preds, _ = asker.predict(doc, missing)
            for key, pred in preds.items():
                if pred.grounded and plausible(pred.value, asker.confirmed.get(key, [])):
                    new[key] = pred.value
        new = {k: tidy(k, v) for k, v in new.items()}
        old = {}
        for source in target["sources"]:
            old.update(source.get("predictedValues") or {})

        stats = Counter()
        for key in sorted(set(gold) | set(new) | set(old)):
            want = (gold.get(key) or "").strip()
            for name, got in (("app", old.get(key, "")), ("new", new.get(key, ""))):
                got = (got or "").strip()
                if want and same(key, got, want):
                    outcome = "ok"
                elif not want and not got:
                    outcome = "both_empty"
                elif not got:
                    outcome = "missing"
                elif not want:
                    outcome = "extra"
                else:
                    outcome = "wrong"
                stats[f"{name}_{outcome}"] += 1
                totals[f"{name}_{outcome}"] += 1
            rows.append({
                "case": tid, "key": key, "gold": want, "app": old.get(key, ""), "new": new.get(key, ""),
                "app_ok": same(key, old.get(key, ""), want) if want else not old.get(key),
                "new_ok": same(key, new.get(key, ""), want) if want else not new.get(key),
            })
        print(
            f"#{tid} {target['sources'][0]['fileName'][:40]:40} "
            f"app ok={stats['app_ok']} wrong={stats['app_wrong']} extra={stats['app_extra']} miss={stats['app_missing']} | "
            f"new ok={stats['new_ok']} wrong={stats['new_wrong']} extra={stats['new_extra']} miss={stats['new_missing']}",
            flush=True,
        )
    print("TOTAL", {k: totals[k] for k in sorted(totals) if not k.endswith("both_empty")})

    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    with out.open("w", newline="", encoding="utf-8-sig") as f:
        writer = csv.DictWriter(f, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)
    print(f"details -> {out}")


if __name__ == "__main__":
    main()
