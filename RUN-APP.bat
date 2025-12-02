@echo off
echo ========================================
echo   Flutter Nurse App - Run on Phone
echo ========================================
echo.
echo Device: SM A165F (R58Y909LCLE)
echo Backend: EC2 at 51.20.164.143
echo.
echo Starting app...
echo.

cd /d "%~dp0"

flutter run -d R58Y909LCLE

pause
