# OCR benchmark (offline)

Compares OCR engines on real scanned PDFs, scored against the values the user finally exported (from `tools/data_export`), so no answers have to be typed by hand.

## Offline rules

- `netguard.py` blocks every network connection; `engines.py` imports it before any OCR library.
- Models are loaded only from `models/` by explicit path.
- `fetch_models.py` is the **only** script that uses the network, run once on the dev machine. SHA256 hashes are pinned in `models/pinned.json`.

## Setup (dev machine)

```sh
cd tools/ocr_bench
python -m venv .venv
.venv/Scripts/python -m pip install torch==2.15.0 torchvision==0.29.2 --index-url https://download.pytorch.org/whl/cpu
.venv/Scripts/python -m pip install -r requirements.txt
.venv/Scripts/python -m pip install vietocr==0.3.13 --no-deps
cp .venv/Lib/site-packages/rapidocr/models/*.onnx models/
.venv/Scripts/python -I fetch_models.py
```

Tesseract (comparison only): `winget install UB-Mannheim.TesseractOCR`.

## Run

`data/` (gitignored: customer data) contains:
- `cases.json`: `[{"id", "pdf_prefix", "history_id"}]`
- `export_histories.json`, `api_logs.jsonl`: output of `tools/data_export`

```sh
.venv/Scripts/python -I -X utf8 bench.py --pdf-dir <PDF folder> --cases data/cases.json \
  --histories data/export_histories.json --logs data/api_logs.jsonl \
  --engines rapid_v6_small,det_vietocr_s2s --dpi 200
```

OCR results are cached in `out/raw/`; `out/summary.csv` and `out/details.csv` hold the scores.

Metrics:
- `pdf_*`: only values Gemini read correctly from that PDF (certainly on the page).
- `num_found`: numeric fields; the digit string must match exactly, no fuzzy match.
