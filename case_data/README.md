# Case data (not in git)

Real dossiers and app data exports used to evaluate and improve the offline
engine. Everything here except this file is ignored by git: it is bank customer
data. Move it by USB or internal channels only, never into commits, issues or
test fixtures (tests use made-up values).

Suggested layout as files are added:

- `exports/`: `docu_fill_data_<MACHINE>_<time>.zip` from Settings → Data → Export analysis data
- `dossiers/`: the source files (PDF, Excel, Word) of the exported cases, named as in the app

Evaluation, from `tools/mapper` (unzip an export first):

```sh
../ocr_bench/.venv/Scripts/python -I -X utf8 evaluate_recent.py <export_histories.json> \
  --dataset data/dataset.jsonl --llm ../ocr_bench/models/llm/Qwen_Qwen3-4B-Instruct-2507-Q4_K_M.gguf
```
