@echo off
cd /d "%~dp0"
echo Starting MaisonLooks local preview...
echo.
echo Server window will stay open while preview is running.
echo URL: http://127.0.0.1:8080/
echo.
start "MaisonLooks Preview Server" powershell.exe -NoExit -NoProfile -ExecutionPolicy Bypass -File "%~dp0serve.ps1" -Port 8080
timeout /t 2 /nobreak > nul
start "" "http://127.0.0.1:8080/"
