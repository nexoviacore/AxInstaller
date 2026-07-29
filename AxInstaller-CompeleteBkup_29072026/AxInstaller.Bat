@echo off
:: Self-elevating batch script

:: Check for admin privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Elevation required. Requesting admin privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: =============================
:: Your commands go below here
:: =============================
echo Running as administrator...

:: Example: Launch your program
start "" "C:\Path\To\YourProgram.exe"

:: Pause so window doesn't close immediately (optional)
pause
