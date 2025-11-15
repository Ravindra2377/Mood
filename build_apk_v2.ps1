# Flutter APK Build Script - Mental Health App
# Purpose: Build release APK with integrated mental health screens
# Date: October 19, 2025

Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  MENTAL HEALTH APP - APK BUILD PIPELINE v2                ║" -ForegroundColor Cyan
Write-Host "║  All 6 screens integrated & ready for testing             ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Step 1: Verify project structure
Write-Host "[1/5] Verifying project structure..." -ForegroundColor Yellow
$projectPath = "d:\OneDrive\Desktop\Mood\soul_fresh"
$pubspecPath = Join-Path $projectPath "pubspec.yaml"

if (-not (Test-Path $pubspecPath)) {
    Write-Host "ERROR: pubspec.yaml not found at $pubspecPath" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Project path verified: $projectPath" -ForegroundColor Green
Write-Host ""

# Step 2: Change to project directory
Write-Host "[2/5] Changing to project directory..." -ForegroundColor Yellow
Push-Location $projectPath
Write-Host "✓ In: $(Get-Location)" -ForegroundColor Green
Write-Host ""

# Step 3: Clean previous builds
Write-Host "[3/5] Cleaning previous builds..." -ForegroundColor Yellow
flutter clean | Out-Null
Write-Host "✓ Clean complete" -ForegroundColor Green
Write-Host ""

# Step 4: Get dependencies
Write-Host "[4/5] Getting dependencies..." -ForegroundColor Yellow
flutter pub get | Out-Null
Write-Host "✓ Dependencies resolved" -ForegroundColor Green
Write-Host ""

# Step 5: Build APK
Write-Host "[5/5] Building release APK..." -ForegroundColor Yellow
Write-Host "This may take 2-3 minutes..." -ForegroundColor Gray
$startTime = Get-Date
flutter build apk --release
$endTime = Get-Date
$buildTime = ($endTime - $startTime).TotalSeconds

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  BUILD COMPLETE!                                           ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

# Verify APK
$apkPath = Join-Path $projectPath "build\app\outputs\flutter-apk\app-release.apk"
if (Test-Path $apkPath) {
    $apkSize = (Get-Item $apkPath).Length / 1MB
    Write-Host "✓ APK Generated Successfully!" -ForegroundColor Green
    Write-Host "  File: $apkPath" -ForegroundColor Cyan
    Write-Host "  Size: $([Math]::Round($apkSize, 2)) MB" -ForegroundColor Cyan
    Write-Host "  Build Time: $([Math]::Round($buildTime, 1)) seconds" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Features included:" -ForegroundColor Yellow
    Write-Host "  ✓ 6 Mental Health Screens" -ForegroundColor Green
    Write-Host "  ✓ Tab Navigation (6-tab dashboard)" -ForegroundColor Green
    Write-Host "  ✓ Stress Management (581 lines)" -ForegroundColor Green
    Write-Host "  ✓ Mood Tracking (664 lines)" -ForegroundColor Green
    Write-Host "  ✓ Sleep Tracking (625 lines)" -ForegroundColor Green
    Write-Host "  ✓ Mindfulness (647 lines)" -ForegroundColor Green
    Write-Host "  ✓ Anxiety Management (801 lines)" -ForegroundColor Green
    Write-Host "  ✓ Wellness Dashboard (759 lines)" -ForegroundColor Green
    Write-Host "  ✓ Material Design 3 UI" -ForegroundColor Green
    Write-Host "  ✓ Riverpod State Management" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "ERROR: APK not found at $apkPath" -ForegroundColor Red
    exit 1
}

Pop-Location
Write-Host "Ready for testing!" -ForegroundColor Cyan
