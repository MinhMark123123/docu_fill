# DocuFill offline engine

PDF OCR and field mapping for the desktop app, without any network access. The app runs `engine\docufill_engine.exe` (next to `docu_fill.exe`) as a child process; see the protocol in `docufill_engine.py`.

- **OCR**: PP-OCRv6 detection + VietOCR (on ONNX, no torch) and PP-OCRv6 recognition; numbers the two recognizers disagree on are masked (`⁇`) so the value goes to review (`tools/ocr_bench`).
- **Mapping**: fields read from the structure of the appraisal form (`tools/mapper/domain.py`), rules learned from the user's past exports, then optionally the local LLM (Qwen3-4B, llama.cpp) for empty fields (`tools/mapper`). Values below the auto-accept confidence, from the LLM, or with a masked number are returned with `review: true`; the app shows them with a yellow border.
- **Certificates**: the certificate scanned in a PDF is read (parcel, map sheet, area, number) and compared with the values taken from the report. It never overrules them: a difference is shown as a note on the field (`tools/mapper/certificate.py`). The legal papers listed in the report fill the certificate and "căn cứ pháp lý" fields.
- **Learning**: the app sends its export history (source text, exported values, proposed values). Exports where the user changed under 3% of the proposed values are not learned from: nobody checked them (`tools/mapper/reviewed.py`). Cases from another machine are read from `%LOCALAPPDATA%\DocuFill\engine_cases\`, not Documents, which OneDrive may sync to the cloud (`export_histories.json` of the in-app data export, or `dataset.jsonl` of `tools/data_export`). Learned rules are cached in `%LOCALAPPDATA%\DocuFill\engine_cache`.
- **OCR cache**: results are cached by file content in the same folder (`ocr_*.json`, the 20 most recently used), so importing the same PDF again costs no OCR. They hold customer text; delete the folder to clear them.
- **No network**: `netguard` replaces the socket functions before any library loads; models are loaded only from `engine\models\`.

## Build

Needs the dev venv and models of `tools/ocr_bench` (see its README) plus `pyinstaller`. The VietOCR graphs come from `tools/ocr_bench/export_vietocr_onnx.py` (needs `onnx`, dev machine only):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File engine\build.ps1            # ~3.2 GB
powershell -NoProfile -ExecutionPolicy Bypass -File engine\build.ps1 -SkipLlm   # ~0.8 GB, no local LLM
```

Then the installer with the engine:

```powershell
cd apps\desktop
flutter build windows --release
& "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" /DWithEngine installer\windows_inno_script.iss
```

## Development

Run the app against the Python sources instead of the frozen build:

```powershell
$env:DOCUFILL_ENGINE = "D:\...\docu_fill\engine\docufill_engine.py"
$env:DOCUFILL_PYTHON = "D:\...\docu_fill\tools\ocr_bench\.venv\Scripts\python.exe"
flutter run -d windows
```

Bump `VERSION` in `docufill_engine.py` with every change to `tools/mapper`, so cached rules from an older version are not reused.
