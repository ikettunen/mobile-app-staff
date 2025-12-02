@echo off
echo Fixing S3 service localhost references...
cd /d "%~dp0"

powershell -Command "(Get-Content 'lib\services\aws_s3_service.dart') -replace 'http://localhost:3001', 'http://51.20.164.143:3001' | Set-Content 'lib\services\aws_s3_service.dart'"

echo Done! All localhost:3001 replaced with 51.20.164.143:3001
pause
