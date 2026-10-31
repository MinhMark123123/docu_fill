<#
.SYNOPSIS
  Collects the data of the DocuFill app installed on this Windows machine into one zip.

.DESCRIPTION
  The zip contains:
    - docu_fill.isar     : Isar database (templates, settings, export history)
    - api_logs\          : Gemini prompt/response logs (Word/Excel raw text + JSON result)
    - templates\         : imported .docx/.xlsx templates
    - libisar.dll        : Isar library from the install folder (to read the database elsewhere)
    - manifest.json      : machine, collection time, file counts, checksum

  The zip holds customer data and the Gemini API key. Move it by USB or internal channels only.

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File collect_docu_fill_data.ps1
  powershell -NoProfile -ExecutionPolicy Bypass -File collect_docu_fill_data.ps1 -OutputDir E:\
#>
param(
  # Folder for the resulting zip. Default: Desktop.
  [string]$OutputDir = [Environment]::GetFolderPath('Desktop'),
  # Documents folder the app uses. Default: the current user's Documents (also when redirected by OneDrive).
  [string]$DocumentsDir = [Environment]::GetFolderPath('MyDocuments'),
  # App install folder. Default: from the registry, then C:\Program Files\DocuFill.
  [string]$InstallDir,
  # Skip the templates folder (smaller zip).
  [switch]$SkipTemplates,
  # Do not ask when the app is running.
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

Write-Host '=== DocuFill data collection ===' -ForegroundColor Cyan

$dbFile = Join-Path $DocumentsDir 'docu_fill.isar'
if (-not (Test-Path $dbFile)) {
  Write-Host "Database not found: $dbFile" -ForegroundColor Red
  Write-Host 'If the app uses another Documents folder, run again with -DocumentsDir <path>.'
  exit 1
}
Write-Host "Documents : $DocumentsDir"

# Copying the database while the app writes to it can corrupt the copy, so ask to close the app.
$running = Get-Process -Name 'docu_fill' -ErrorAction SilentlyContinue
while ($running -and -not $Force) {
  Write-Host 'DocuFill is running. Close it so the database is not copied mid-write.' -ForegroundColor Yellow
  $answer = Read-Host 'Press Enter after closing the app (or type "skip" to continue anyway)'
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
  Write-Host 'libisar.dll not found in the install folder. Continuing; pass --isar-lib when reading the database.' -ForegroundColor Yellow
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
    Write-Host 'No api_logs folder ("API logging" may be off in Settings).' -ForegroundColor Yellow
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
  Write-Host "Done: $zipPath" -ForegroundColor Green
  Write-Host ("  api_logs : {0} file" -f $manifest.apiLogs.files)
  Write-Host ("  templates: {0} file" -f $manifest.templates.files)
  Write-Host 'Note: the zip holds customer data and the Gemini API key. Move it by USB or internal channels only.' -ForegroundColor Yellow
} finally {
  Remove-Item $staging -Recurse -Force -ErrorAction SilentlyContinue
}
