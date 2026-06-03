@echo off
cd /d "%~dp0"
title MaisonLooks Preview Server
echo MaisonLooks local preview
echo.
echo Keep this window open.
echo Open this URL in your browser:
echo.
echo   http://127.0.0.1:8080/
echo.
echo If this window shows an error, copy the error text.
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0serve.ps1" -Port 8080
echo.
echo Server stopped or failed.
pause
