# DocuFill data export

Collects the data of the DocuFill app installed on a Windows machine, for rule-based mapping, few-shot examples and test sets (see the offline mapping context files).

The app itself can also do this: Settings → Data → Export analysis data writes the same content as a zip, without this tool.

## 1. Collect on each machine with the app

Copy `tools/data_export` (only `collect_docu_fill_data.bat` and `.ps1` are needed) to the machine, close DocuFill and double-click `collect_docu_fill_data.bat`.

Result: `docu_fill_data_<MACHINE>_<time>.zip` on the Desktop, containing:

| File | Content |
|---|---|
| `docu_fill.isar` | Database: templates (key/label/description), settings, export history (the values the user finally confirmed) |
| `api_logs/` | Gemini prompts and responses: Word/Excel raw text and the JSON Gemini returned (only when API logging is on in Settings) |
| `templates/` | Imported template files |
| `libisar.dll` | From the install folder, to read the database on another machine |
| `manifest.json` | Machine, user, time, database checksum |

Options: `-OutputDir E:\` (write straight to a USB drive), `-DocumentsDir`, `-InstallDir`, `-SkipTemplates`, `-Force`.

> The zip holds customer data and the Gemini API key. Move it by USB or internal channels only.

## 2. Convert to JSON on the dev machine

```sh
cd tools/data_export
dart pub get
dart run bin/export_dataset.dart path/to/machine1.zip path/to/machine2.zip --out out
```

Output in `out/<MACHINE>/`:

- `templates.json`, `settings.json` (API key redacted), `export_histories.json`
- `api_logs.jsonl`: one Gemini call per line, with `mode` (`text` = Word/Excel, `file` = PDF/image), `fields`, `rawText`, `response`
- `dataset.jsonl`: **raw source → final values** pairs, with `sources[].rawText`, `sources[].geminiOutput`, `finalValues`, `fieldDescriptions`

`out/dataset_all.jsonl` merges the datasets of all machines.

## Limitations

- Logs are paired with export history by **value overlap** (`matchScore` ≥ 0.5, at least 3 matching values), because older app versions did not store `createdAt`. Some pairs can be wrong; filter by `matchScore` when precision matters.
- For PDFs (`mode: file`) the app keeps only the file name, not the file. The original PDFs must be collected by `fileName` for OCR.
- Logs exist only from the time API logging was turned on.
