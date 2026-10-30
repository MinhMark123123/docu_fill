<#
.SYNOPSIS
  Thu thap du lieu cua app DocuFill da cai tren may Windows thanh 1 file zip.

.DESCRIPTION
  Gom cac file sau vao zip:
    - docu_fill.isar     : database Isar (templates, settings, lich su xuat file)
    - api_logs\          : log prompt/response Gemini (raw text Word/Excel + JSON ket qua)
    - templates\         : file template .docx/.xlsx da import
    - libisar.dll        : thu vien Isar lay tu thu muc cai app (de doc database tren may khac)
    - manifest.json      : thong tin may, thoi diem thu thap, so luong file, checksum

  Zip nay chua du lieu khach hang va Gemini API key. Chi chuyen qua USB/kenh noi bo.

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File collect_docu_fill_data.ps1
  powershell -NoProfile -ExecutionPolicy Bypass -File collect_docu_fill_data.ps1 -OutputDir E:\
#>
param(
  # Thu muc chua file zip ket qua. Mac dinh: Desktop.
  [string]$OutputDir = [Environment]::GetFolderPath('Desktop'),
  # Thu muc Documents ma app dung. Mac dinh: Documents cua user hien tai (ke ca khi bi OneDrive chuyen huong).
  [string]$DocumentsDir = [Environment]::GetFolderPath('MyDocuments'),
  # Thu muc cai app. Mac dinh: tim trong registry, sau do C:\Program Files\DocuFill.
  [string]$InstallDir,
  # Bo qua thu muc templates (giam dung luong zip).
  [switch]$SkipTemplates,
  # Khong hoi khi app dang chay.
  [switch]$Force
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Find-InstallDir {
  $keys = @(
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
  )
  $entry = Get-ItemProperty $keys -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -like 'DocuFill*' } |
    Select-Object -First 1
  if ($entry -and $entry.InstallLocation -and (Test-Path $entry.InstallLocation)) {
    return $entry.InstallLocation
  }
  $fallback = Join-Path $env:ProgramFiles 'DocuFill'
  if (Test-Path $fallback) { return $fallback }
  return $null
}

function Get-FolderStats([string]$path) {
  if (-not (Test-Path $path)) { return @{ files = 0; bytes = 0 } }
  $m = Get-ChildItem $path -File -Recurse | Measure-Object -Sum Length
  return @{ files = $m.Count; bytes = [long]($m.Sum) }
}

Write-Host '=== Thu thap du lieu DocuFill ===' -ForegroundColor Cyan

$dbFile = Join-Path $DocumentsDir 'docu_fill.isar'
if (-not (Test-Path $dbFile)) {
  Write-Host "Khong tim thay database: $dbFile" -ForegroundColor Red
  Write-Host 'Neu app luu o thu muc Documents khac, chay lai voi -DocumentsDir <duong_dan>.'
  exit 1
}
Write-Host "Documents : $DocumentsDir"

# Copy database khi app dang ghi co the cho ra file loi -> yeu cau dong app.
$running = Get-Process -Name 'docu_fill' -ErrorAction SilentlyContinue
while ($running -and -not $Force) {
  Write-Host 'App DocuFill dang chay. Hay dong app de database khong bi ghi do.' -ForegroundColor Yellow
  $answer = Read-Host 'Nhan Enter sau khi dong app (hoac go "skip" de van tiep tuc)'
  if ($answer -eq 'skip') { break }
  $running = Get-Process -Name 'docu_fill' -ErrorAction SilentlyContinue
}

if (-not $InstallDir) { $InstallDir = Find-InstallDir }
$isarLib = $null
if ($InstallDir) {
  $candidate = Join-Path $InstallDir 'libisar.dll'
  if (Test-Path $candidate) { $isarLib = $candidate }
}
if ($isarLib) {
  Write-Host "App       : $InstallDir"
} else {
  Write-Host 'Khong tim thay libisar.dll trong thu muc cai app. Van tiep tuc, nhung khi doc database can chi dinh --isar-lib.' -ForegroundColor Yellow
}

$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$machine = $env:COMPUTERNAME
$baseName = "docu_fill_data_${machine}_${stamp}"
$staging = Join-Path $env:TEMP $baseName
New-Item -ItemType Directory -Force $staging | Out-Null

try {
  Copy-Item $dbFile (Join-Path $staging 'docu_fill.isar')

  $logsDir = Join-Path $DocumentsDir 'api_logs'
  if (Test-Path $logsDir) {
    Copy-Item $logsDir (Join-Path $staging 'api_logs') -Recurse
  } else {
    Write-Host 'Khong co thu muc api_logs (co the chua bat "API logging" trong Settings).' -ForegroundColor Yellow
  }

  $templatesDir = Join-Path $DocumentsDir 'templates'
  if ((Test-Path $templatesDir) -and -not $SkipTemplates) {
    Copy-Item $templatesDir (Join-Path $staging 'templates') -Recurse
  }

  if ($isarLib) { Copy-Item $isarLib (Join-Path $staging 'libisar.dll') }

  $appVersion = $null
  if ($InstallDir) {
    $exe = Join-Path $InstallDir 'docu_fill.exe'
    if (Test-Path $exe) { $appVersion = (Get-Item $exe).VersionInfo.FileVersion }
  }

  $manifest = [ordered]@{
    machine       = $machine
    user          = $env:USERNAME
    collectedAt   = (Get-Date).ToString('o')
    documentsDir  = $DocumentsDir
    installDir    = $InstallDir
    appVersion    = $appVersion
    appWasRunning = [bool]$running
    database      = @{
      bytes  = (Get-Item $dbFile).Length
      sha256 = (Get-FileHash (Join-Path $staging 'docu_fill.isar') -Algorithm SHA256).Hash
    }
    apiLogs       = Get-FolderStats (Join-Path $staging 'api_logs')
    templates     = Get-FolderStats (Join-Path $staging 'templates')
  }
  $manifestJson = $manifest | ConvertTo-Json -Depth 5
  [System.IO.File]::WriteAllText((Join-Path $staging 'manifest.json'), $manifestJson, (New-Object System.Text.UTF8Encoding $false))

  New-Item -ItemType Directory -Force $OutputDir | Out-Null
  $zipPath = Join-Path $OutputDir "$baseName.zip"
  [System.IO.Compression.ZipFile]::CreateFromDirectory($staging, $zipPath, [System.IO.Compression.CompressionLevel]::Optimal, $false)

  Write-Host ''
  Write-Host "Xong: $zipPath" -ForegroundColor Green
  Write-Host ("  api_logs : {0} file" -f $manifest.apiLogs.files)
  Write-Host ("  templates: {0} file" -f $manifest.templates.files)
  Write-Host 'Luu y: zip chua du lieu khach hang va Gemini API key, chi chuyen qua USB/kenh noi bo.' -ForegroundColor Yellow
} finally {
  Remove-Item $staging -Recurse -Force -ErrorAction SilentlyContinue
}
