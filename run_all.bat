@echo off
TITLE Starbucks TP Automator
echo ============================================
echo   🚀 STARBUCKS TP - AUTOMATED PIPELINE 🚀
echo ============================================
echo.
powershell -ExecutionPolicy Bypass -File ".\run_all.ps1"
if %errorlevel% neq 0 (
    echo.
    echo ❌ Something went wrong. Check the logs above.
    pause
    exit /b %errorlevel%
)
echo.
echo ✅ ALL STEPS COMPLETED!
echo.
pause
