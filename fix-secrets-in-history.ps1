# Fix AWS secrets in git history
# This will amend the commits to remove the secrets

Write-Host "Fixing AWS secrets in git history..." -ForegroundColor Yellow
Write-Host ""

# Check if app_config.dart still has the old secrets
$configFile = "lib/core/config/app_config.dart"
$content = Get-Content $configFile -Raw

if ($content -match "AKIAV76ZJRZPKOIO3ZFJ") {
    Write-Host "ERROR: app_config.dart still contains AWS secrets!" -ForegroundColor Red
    Write-Host "Please ensure the file has been updated with empty strings." -ForegroundColor Red
    exit 1
}

Write-Host "Step 1: Checking current status..." -ForegroundColor Cyan
git status

Write-Host ""
Write-Host "Step 2: We need to rewrite the commit history." -ForegroundColor Cyan
Write-Host "This will modify commits: 9df99b4, e2af3e8, and ef01a79" -ForegroundColor Yellow
Write-Host ""
Write-Host "Option 1 (Recommended): Reset and recommit" -ForegroundColor Green
Write-Host "  This will reset to the last pushed commit and create a new clean commit" -ForegroundColor White
Write-Host ""
Write-Host "Commands to run:" -ForegroundColor Cyan
Write-Host "  git reset --soft origin/main" -ForegroundColor White
Write-Host "  git add ." -ForegroundColor White
Write-Host "  git commit -m 'feat: transcription working, visit list improvements, remove secrets'" -ForegroundColor White
Write-Host "  git push" -ForegroundColor White
Write-Host ""
Write-Host "This will combine all your changes into one clean commit without secrets." -ForegroundColor Green
