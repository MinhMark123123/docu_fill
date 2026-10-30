# Rule mapper (offline)

Học luật trích xuất cho từng key từ các hồ sơ đã xuất (text nguồn + giá trị người dùng xác nhận), không dùng AI. Mỗi luật = cách tìm ô (nhãn → chính ô đó / ô bên phải / ô bên dưới) + cách cắt giá trị + cách đổi định dạng (ngày, số). Độ tin cậy = cận dưới Wilson của tỉ lệ luật cho ra đúng giá trị; dưới ngưỡng thì để trống.

- `rawdoc.py`: tài liệu nguồn dạng hàng/ô (Excel, Word, OCR qua `tools/ocr_bench/layout.py`)
- `learner.py`: sinh luật, chấm độ tin cậy, dự đoán
- `evaluate.py`: leave-one-out so với Gemini

```sh
../ocr_bench/.venv/Scripts/python -I -X utf8 evaluate.py data/dataset.jsonl
```

`data/dataset.jsonl` là output của `tools/data_export` (bị gitignore vì chứa dữ liệu khách hàng).

Kết quả hiện tại (30 hồ sơ Word/Excel): đúng 24.3% (Gemini 59.1%), chính xác khi điền ~77%. Đường cong học đi ngang từ ~15 hồ sơ, nên bước tiếp theo là LLM chạy trên máy cho các trường văn bản tự do.
