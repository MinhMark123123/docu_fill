# OCR benchmark (offline)

So sánh các engine OCR trên PDF scan thật, chấm điểm bằng giá trị cuối cùng người dùng đã xuất (lấy từ `tools/data_export`), không cần gõ tay đáp án.

## Nguyên tắc offline

- `netguard.py` chặn mọi kết nối mạng; `engines.py` import nó trước mọi thư viện OCR.
- Model chỉ nạp từ `models/` bằng đường dẫn cụ thể.
- `fetch_models.py` là script **duy nhất** dùng mạng, chỉ chạy một lần trên máy dev. Hash SHA256 được ghim trong `models/pinned.json`.

## Cài đặt (máy dev)

```sh
cd tools/ocr_bench
python -m venv .venv
.venv/Scripts/python -m pip install torch==2.15.0 torchvision==0.29.2 --index-url https://download.pytorch.org/whl/cpu
.venv/Scripts/python -m pip install -r requirements.txt
.venv/Scripts/python -m pip install vietocr==0.3.13 --no-deps
cp .venv/Lib/site-packages/rapidocr/models/*.onnx models/
.venv/Scripts/python -I fetch_models.py
```

Tesseract (chỉ để so sánh): `winget install UB-Mannheim.TesseractOCR`.

## Chạy

`data/` (bị gitignore vì chứa dữ liệu khách hàng) gồm:
- `cases.json`: `[{"id", "pdf_prefix", "history_id"}]`
- `export_histories.json`, `api_logs.jsonl`: output của `tools/data_export`

```sh
.venv/Scripts/python -I -X utf8 bench.py --pdf-dir <thư mục PDF> --cases data/cases.json \
  --histories data/export_histories.json --logs data/api_logs.jsonl \
  --engines rapid_v6_small,det_vietocr_s2s --dpi 200
```

Kết quả OCR được cache trong `out/raw/`; `out/summary.csv` và `out/details.csv` chứa điểm.

Chỉ số:
- `pdf_*`: chỉ tính giá trị Gemini đã đọc đúng từ chính PDF đó (chắc chắn có trên trang).
- `num_found`: trường số; chuỗi chữ số phải đúng hoàn toàn, không tính khớp gần đúng.
