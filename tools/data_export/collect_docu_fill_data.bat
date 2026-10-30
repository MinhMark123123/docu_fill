@echo off
rem Double-click de thu thap du lieu DocuFill. Zip se nam tren Desktop.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0collect_docu_fill_data.ps1" %*
pause
