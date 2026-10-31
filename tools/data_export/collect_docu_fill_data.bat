@echo off
rem Double-click to collect DocuFill data. The zip is written to the Desktop.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0collect_docu_fill_data.ps1" %*
pause
