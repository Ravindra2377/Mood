Write-Host "Starting APK Build..." -ForegroundColor Cyan
$projectPath = "d:\OneDrive\Desktop\Mood\soul_fresh"
Push-Location $projectPath

Write-Host "Cleaning..." -ForegroundColor Yellow
flutter clean | Out-Null

Write-Host "Getting dependencies..." -ForegroundColor Yellow
flutter pub get | Out-Null

Write-Host "Building APK (this takes 2-3 minutes)..." -ForegroundColor Yellow
flutter build apk --release

Write-Host ""
Write-Host "Build complete! Checking APK..." -ForegroundColor Green
$apkPath = "build\app\outputs\flutter-apk\app-release.apk"
if (Test-Path $apkPath) {
    $size = (Get-Item $apkPath).Length / 1MB
    Write-Host "APK Ready: $apkPath" -ForegroundColor Green
    Write-Host "Size: $([Math]::Round($size, 2)) MB" -ForegroundColor Green
} else {
    Write-Host "APK not found!" -ForegroundColor Red
}
Pop-Location
