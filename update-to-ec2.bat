@echo off
echo Updating localhost references to EC2 IP (51.20.164.143)...

cd /d "%~dp0"

:: Use PowerShell for string replacement (works in CMD)
powershell -Command "(Get-Content 'lib\services\aws_s3_service.dart') -replace 'http://localhost:3001', 'http://51.20.164.143:3001' | Set-Content 'lib\services\aws_s3_service.dart'"

echo Done! All localhost:3001 references updated to 51.20.164.143:3001
echo.
echo You can now run: flutter run
pause
