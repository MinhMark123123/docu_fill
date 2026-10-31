<#
.SYNOPSIS
  Builds the offline engine into engine\build\dist\docufill_engine (folder with
  docufill_engine.exe and models\), ready to be copied next to docu_fill.exe
  as "engine\".

.DESCRIPTION
  Uses the dev venv of tools\ocr_bench (torch CPU, rapidocr, vietocr,
  llama-cpp-python, pyinstaller) and the models fetched by
  tools\ocr_bench\fetch_models.py. Nothing is downloaded here.

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File engine\build.ps1
  powershell -NoProfile -ExecutionPolicy Bypass -File engine\build.ps1 -SkipLlm
#>
param(
  # Leave the 2.5 GB LLM out (OCR and learned rules only).
  [switch]$SkipLlm
)

$ErrorActionPreference = 'Stop'
$engineDir = $PSScriptRoot
$repo = Split-Path $engineDir -Parent
$python = Join-Path $repo 'tools\ocr_bench\.venv\Scripts\python.exe'
$models = Join-Path $repo 'tools\ocr_bench\models'
$build = Join-Path $engineDir 'build'
$dist = Join-Path $build 'dist\docufill_engine'

# torchvision loads its native ops from its own folder by path; PyInstaller
# does not collect these .pyd files on its own.
$torchvision = Join-Path $repo 'tools\ocr_bench\.venv\Lib\site-packages\torchvision'

# --windowed: the app starts the engine as a child process; a console build
# would pop up a console window over the app. stderr still reaches the app
# through the pipe it passes.
& $python -m PyInstaller --noconfirm --clean --onedir --windowed `
  --name docufill_engine `
  --distpath (Join-Path $build 'dist') `
  --workpath (Join-Path $build 'work') `
  --specpath $build `
  --paths (Join-Path $repo 'tools\ocr_bench') `
  --paths (Join-Path $repo 'tools\mapper') `
  --collect-all llama_cpp `
  --collect-data rapidocr `
  --collect-data pymupdf `
  --collect-submodules vietocr `
  --copy-metadata gdown `
  --add-binary "$torchvision\_C_stable.pyd;torchvision" `
  --add-binary "$torchvision\image_stable.pyd;torchvision" `
  --exclude-module tkinter `
  --exclude-module matplotlib `
  (Join-Path $engineDir 'docufill_engine.py')
if ($LASTEXITCODE -ne 0) { throw "PyInstaller failed ($LASTEXITCODE)" }

# Only the models the engine uses.
$needed = @(
  'PP-OCRv6_det_small.onnx',
  'PP-OCRv6_rec_small.onnx',
  'ch_ppocr_mobile_v2.0_cls_mobile.onnx',
  'vietocr\base.yml',
  'vietocr\vgg-seq2seq.yml',
  'vietocr\vgg_seq2seq.pth'
)
if (-not $SkipLlm) { $needed += 'llm\Qwen_Qwen3-4B-Instruct-2507-Q4_K_M.gguf' }
foreach ($name in $needed) {
  $source = Join-Path $models $name
  if (-not (Test-Path $source)) { throw "Missing model: $source (run tools\ocr_bench\fetch_models.py)" }
  $target = Join-Path $dist "models\$name"
  New-Item -ItemType Directory -Force (Split-Path $target -Parent) | Out-Null
  Copy-Item $source $target
}

$size = (Get-ChildItem $dist -Recurse -File | Measure-Object -Sum Length).Sum / 1MB
Write-Host ("Engine built: {0} ({1:N0} MB)" -f $dist, $size) -ForegroundColor Green
