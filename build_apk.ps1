# Build APK Script for Flutter Mental Health App
$projectPath = "d:\OneDrive\Desktop\Mood\soul_fresh"
$outputPath = "$projectPath\build\app\outputs\apk\release"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Flutter APK Build Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check if project exists
if (!(Test-Path "$projectPath\pubspec.yaml")) {
    Write-Host "ERROR: pubspec.yaml not found at $projectPath" -ForegroundColor Red
    exit 1
}

Write-Host "[1/5] Project path verified" -ForegroundColor Green

# Step 2: Change to project directory
Set-Location $projectPath
Write-Host "[2/5] Changed to project directory" -ForegroundColor Green

# Step 3: Clean previous builds
Write-Host "[3/5] Cleaning previous builds..." -ForegroundColor Yellow
flutter clean
Write-Host "      Complete" -ForegroundColor Green

# Step 4: Get dependencies
Write-Host "[4/5] Getting dependencies..." -ForegroundColor Yellow
flutter pub get
Write-Host "      Complete" -ForegroundColor Green

# Step 5: Build release APK
Write-Host "[5/5] Building release APK (this may take several minutes)..." -ForegroundColor Yellow
flutter build apk --release

# Check if build succeeded
$apkFile = "$outputPath\app-release.apk"
if (Test-Path $apkFile) {
    $fileSize = (Get-Item $apkFile).Length / 1MB
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "BUILD SUCCESSFUL!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "APK Location: $apkFile" -ForegroundColor Cyan
    Write-Host "APK Size: $fileSize MB" -ForegroundColor Cyan
    Write-Host ""
}
else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "BUILD FAILED!" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "APK not found at: $apkFile" -ForegroundColor Yellow
}
