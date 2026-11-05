# Field mapper (offline)

Maps a source document (Word/Excel text, or OCR via `tools/ocr_bench/layout.py`) to template keys, learning from past exports (source text + values the user confirmed). Nothing leaves the machine.

0. **Form structure** (`domain.py`, no AI): what the bank's appraisal form states by label, and conventions seen in the user's corrections (report date, percentages, the customer's address under "Khách hàng"). It wins over rules and the LLM, and can leave a key empty on purpose (a comparable with no labeled parcel number). From OCR it reads labeled lines only, not table columns.
1. **Rules** (no AI): each rule = how to find the cell (label → the cell itself / right / below / table row × column) + how to cut the value + how to format it (date, number). Confidence is the Wilson lower bound of the rule's hit rate; below the threshold the key is left empty.
2. **Local LLM** (llama.cpp, GGUF) for the keys the rules leave empty. Keys of one comparable property are asked together and only see that property's column; every number in an answer must exist in the shown cells, and answers are conformed to the format of the confirmed values.

- `domain.py`: fields read from the structure of the form
- `certificate.py`: certificates scanned in a PDF, compared with the report
- `reviewed.py`: tells exports the user checked from those exported as proposed, which are not learned from (under 3% of the proposed values changed)
- `rawdoc.py`: source document as rows/cells, comparison-table columns and row parents
- `learner.py`: rule induction, confidence, prediction
- `llm_mapper.py`: retrieval, prompt, grounding and format checks
- `evaluate.py`: leave-one-out of the rules against Gemini
- `evaluate_llm.py`: leave-one-out of rules + LLM
- `evaluate_recent.py`: leave-one-out on the app's export history, against what the app really proposed at import

```sh
../ocr_bench/.venv/Scripts/python -I -X utf8 evaluate.py data/dataset.jsonl
../ocr_bench/.venv/Scripts/python -I -X utf8 evaluate_llm.py data/dataset.jsonl \
  --model ../ocr_bench/models/llm/Qwen_Qwen3-4B-Instruct-2507-Q4_K_M.gguf --cases 2
```

`data/dataset.jsonl` is the output of `tools/data_export` (gitignored: customer data).

Current results: rules alone 33.3% correct on 30 Word/Excel cases (Gemini 59.1%), ~78% precision when filled. Rules + Qwen3-4B on 2 cases: ~50% correct (Gemini 67.6%), ~6 min per case on the dev CPU.
