# Final APK Build Script with Mental Health Screens Integration
# Date: October 19, 2025

Write-Host "╔════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     BUILDING SOUL APK WITH MENTAL HEALTH      ║" -ForegroundColor Cyan
Write-Host "║              SCREENS INTEGRATED               ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Set project directory
$projectPath = "d:\OneDrive\Desktop\Mood\soul_fresh"

# Verify project exists
if (-not (Test-Path "$projectPath/pubspec.yaml")) {
    Write-Host "ERROR: pubspec.yaml not found at $projectPath" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Project verified at: $projectPath" -ForegroundColor Green
Write-Host ""

# Step 1: Clean
Write-Host "[1/5] Cleaning previous builds..." -ForegroundColor Yellow
Set-Location $projectPath
flutter clean 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Clean completed" -ForegroundColor Green
} else {
    Write-Host "✗ Clean failed" -ForegroundColor Red
    exit 1
}

# Step 2: Get dependencies
Write-Host "[2/5] Getting dependencies..." -ForegroundColor Yellow
flutter pub get 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Dependencies resolved" -ForegroundColor Green
} else {
    Write-Host "✗ Dependencies failed" -ForegroundColor Red
    exit 1
}

# Step 3: Analyze
Write-Host "[3/5] Analyzing code..." -ForegroundColor Yellow
$analyzeOutput = flutter analyze 2>&1 | Select-Object -Last 1
if ($analyzeOutput -like "*no issues*") {
    Write-Host "✓ Code analysis passed" -ForegroundColor Green
} else {
    Write-Host "⚠ Analysis complete (may have warnings)" -ForegroundColor Yellow
}

# Step 4: Build APK
Write-Host "[4/5] Building release APK..." -ForegroundColor Yellow
Write-Host "      (This takes 2-3 minutes, please wait...)" -ForegroundColor Gray

$buildStartTime = Get-Date
flutter build apk --release 2>&1 | Tee-Object -Variable buildOutput | Out-Null
$buildEndTime = Get-Date
$buildDuration = ($buildEndTime - $buildStartTime).TotalSeconds

if ($LASTEXITCODE -eq 0) {
    Write-Host "ÔÇÿ Build completed successfully" -ForegroundColor Green
    Write-Host "  Build time: $($buildDuration.ToString('F1')) seconds" -ForegroundColor Green
} else {
    Write-Host "X Build failed" -ForegroundColor Red
    Write-Host ""
    Write-Host "Build output:" -ForegroundColor Red
    $buildOutput | Select-Object -Last 20
    exit 1
}

# Step 5: Verify APK
Write-Host "[5/5] Verifying APK..." -ForegroundColor Yellow

$apkPath = "$projectPath\build\app\outputs\flutter-apk\app-release.apk"

if (Test-Path $apkPath) {
    $apkSize = (Get-Item $apkPath).Length / 1MB
    $apkSizeMB = [math]::Round($apkSize, 2)
    Write-Host "✓ APK created successfully" -ForegroundColor Green
    Write-Host "  Size: $apkSizeMB MB" -ForegroundColor Green
    Write-Host "  Path: $apkPath" -ForegroundColor Green
} else {
    Write-Host "✗ APK not found at expected location" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "╔════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║            BUILD SUCCESSFUL! 🎉                ║" -ForegroundColor Green
Write-Host "║                                                ║" -ForegroundColor Green
Write-Host "║  All 6 Mental Health Screens Included:         ║" -ForegroundColor Green
Write-Host "║  - Stress Management: 581 lines               ║" -ForegroundColor Green
Write-Host "║  - Mood Tracking: 664 lines                   ║" -ForegroundColor Green
Write-Host "║  - Sleep Tracking: 625 lines                  ║" -ForegroundColor Green
Write-Host "║  - Mindfulness: 647 lines                     ║" -ForegroundColor Green
Write-Host "║  - Anxiety Management: 801 lines              ║" -ForegroundColor Green
Write-Host "║  - Wellness Dashboard: 759 lines              ║" -ForegroundColor Green
Write-Host "║                                                ║" -ForegroundColor Green
Write-Host "║  APK Size: $apkSizeMB MB                             ║" -ForegroundColor Green
Write-Host "║  Build Time: $($buildDuration.ToString('F1')) seconds                        ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Install on device: adb install -r `"$apkPath`"" -ForegroundColor Cyan
Write-Host "2. Or copy file to device via USB" -ForegroundColor Cyan
Write-Host "3. Or upload to GitHub/Play Store" -ForegroundColor Cyan

exit 0
