# DocuFill data export

Tool này lấy dữ liệu từ app DocuFill đã cài trên máy Windows để làm dữ liệu cho rule-based mapping, few-shot và bộ test (xem các file context về offline mapping).

## 1. Thu thập trên từng máy có cài app

Chép thư mục `tools/data_export` (chỉ cần 2 file `collect_docu_fill_data.bat` và `.ps1`) sang máy cần lấy dữ liệu, đóng app DocuFill rồi double-click `collect_docu_fill_data.bat`.

Kết quả: file `docu_fill_data_<TÊN_MÁY>_<thời_gian>.zip` trên Desktop, gồm:

| File | Nội dung |
|---|---|
| `docu_fill.isar` | Database: templates (key/label/description), settings, lịch sử xuất file (giá trị cuối cùng người dùng đã xác nhận) |
| `api_logs/` | Prompt + response của Gemini: raw text Word/Excel và JSON Gemini trả về (chỉ có khi bật API logging trong Settings) |
| `templates/` | File template đã import |
| `libisar.dll` | Lấy từ thư mục cài app, dùng để đọc database ở máy khác |
| `manifest.json` | Tên máy, user, thời gian, checksum database |

Tham số tùy chọn: `-OutputDir E:\` (ghi thẳng ra USB), `-DocumentsDir`, `-InstallDir`, `-SkipTemplates`, `-Force`.

> Zip chứa dữ liệu khách hàng và Gemini API key. Chỉ chuyển qua USB hoặc kênh nội bộ.

## 2. Chuyển thành JSON trên máy dev

```sh
cd tools/data_export
dart pub get
dart run bin/export_dataset.dart path/to/may1.zip path/to/may2.zip --out out
```

Output trong `out/<TÊN_MÁY>/`:

- `templates.json`, `settings.json` (API key đã che), `export_histories.json`
- `api_logs.jsonl`: mỗi dòng là 1 lần gọi Gemini, gồm `mode` (`text` = Word/Excel, `file` = PDF/ảnh), `fields`, `rawText`, `response`
- `dataset.jsonl`: các cặp **raw nguồn → giá trị cuối cùng**, gồm `sources[].rawText`, `sources[].geminiOutput`, `finalValues`, `fieldDescriptions`

`out/dataset_all.jsonl` gộp dataset của tất cả các máy.

## Giới hạn

- Log được ghép với lịch sử xuất file theo **mức trùng giá trị** (`matchScore` ≥ 0.5, tối thiểu 3 giá trị khớp). Không ghép theo thời gian được vì app không lưu `createdAt` của export history. Một số cặp có thể bị ghép sai, nên lọc theo `matchScore` khi cần độ chính xác cao.
- Với PDF (`mode: file`), app không lưu file gốc, chỉ có tên file. Cần tự thu file PDF gốc theo `fileName` để làm OCR.
- Log chỉ có từ lúc bật API logging trong Settings.
