<#
.SYNOPSIS
  Build the Flutter SOUL app APK locally with one command.

.DESCRIPTION
  Convenience PowerShell helper for building the Flutter APK from the Flutter app at ../soul.
  - Verifies Flutter CLI is available.
  - Optionally runs `flutter create .` if android/ is missing.
  - Runs `flutter pub get` and (by default) code generation (`build_runner`).
  - Builds debug or release APK with a provided BASE_URL via --dart-define.
  - Optionally installs the APK to a connected device via adb.

.PARAMETER ProjectPath
  Path to the Flutter project root. Defaults to ../soul (relative to this script).

.PARAMETER BaseUrl
  Backend base URL passed to the app via --dart-define=BASE_URL=<value>.

.PARAMETER Release
  Build a release APK (otherwise a debug APK).

.PARAMETER SkipCodegen
  Skip running build_runner code generation.

.PARAMETER CreateScaffold
  Run `flutter create .` if the Flutter android/ folder is missing.

.PARAMETER BuildName
  Optional build name to pass to Flutter (e.g., 1.0.3).

.PARAMETER BuildNumber
  Optional build number to pass to Flutter (e.g., 42).

.PARAMETER ExtraDefine
  Optional list of additional --dart-define entries, e.g. KEY=VALUE.

.PARAMETER Install
  After build, install the APK to a connected device using adb.

.PARAMETER DeviceId
  Optional specific device ID for adb install (from `adb devices`).

.PARAMETER OpenFolder
  Open the output folder in Explorer when finished.

.EXAMPLE
  # Debug build against staging and install it:
  .\flutter_build.ps1 -BaseUrl https://api-staging.soulapp.app -Install

.EXAMPLE
  # Release build for production with explicit version:
  .\flutter_build.ps1 -Release -BaseUrl https://api.soulapp.app -BuildName 1.0.0 -BuildNumber 1

.NOTES
  Requires: Flutter SDK on PATH, optional Android SDK/adb for install.
#>

[CmdletBinding()]
param(
  [string]$ProjectPath = (Join-Path -Path (Split-Path -Parent $PSCommandPath) -ChildPath "..\soul" | Resolve-Path),
  [Parameter(Mandatory = $true)]
  [string]$BaseUrl,
  [switch]$Release,
  [switch]$SkipCodegen,
  [switch]$CreateScaffold,
  [string]$BuildName,
  [string]$BuildNumber,
  [string[]]$ExtraDefine = @(),
  [switch]$Install,
  [string]$DeviceId,
  [switch]$OpenFolder
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Info($msg) { Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Warn($msg) { Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-Err($msg)  { Write-Host "[ERR ] $msg" -ForegroundColor Red }
function Write-Ok($msg)   { Write-Host "[ OK ] $msg" -ForegroundColor Green }

function Assert-Command($name) {
  if (-not (Get-Command $name -ErrorAction SilentlyContinue)) {
    throw "Required command not found: $name. Ensure it is installed and on PATH."
  }
}

function Invoke-Tool([string]$Exe, [string[]]$Args, [switch]$AllowFail) {
  Write-Info "$Exe $($Args -join ' ')"
  $psi = New-Object System.Diagnostics.ProcessStartInfo
  $psi.FileName = $Exe
  $psi.ArgumentList.AddRange($Args)
  $psi.RedirectStandardOutput = $true
  $psi.RedirectStandardError  = $true
  $psi.UseShellExecute = $false
  $psi.CreateNoWindow = $true

  $p = New-Object System.Diagnostics.Process
  $p.StartInfo = $psi
  [void]$p.Start()
  $out = $p.StandardOutput.ReadToEnd()
  $err = $p.StandardError.ReadToEnd()
  $p.WaitForExit()

  if ($out) { Write-Host $out }
  if ($err) { Write-Warn $err }

  if (-not $AllowFail -and $p.ExitCode -ne 0) {
    throw "$Exe exited with code $($p.ExitCode)"
  }
  return $p.ExitCode
}

# -- Preflight ----------------------------------------------------------------
Assert-Command flutter
if ($Install) { Assert-Command adb }

if (-not (Test-Path -LiteralPath $ProjectPath)) {
  throw "Flutter project path not found: $ProjectPath"
}

# Normalize to full path
$ProjectPath = (Resolve-Path $ProjectPath).Path
Set-Location $ProjectPath
Write-Info "Working directory: $ProjectPath"

# Scaffold if missing android folder
if ($CreateScaffold -and -not (Test-Path -LiteralPath (Join-Path $ProjectPath 'android'))) {
  Write-Info "android/ not found. Running 'flutter create .' to scaffold platform folders..."
  Invoke-Tool flutter @('create','.') | Out-Null
  Write-Ok "Flutter platform scaffold created."
}

# -- Dependencies & codegen ---------------------------------------------------
Write-Info "Fetching Flutter dependencies..."
Invoke-Tool flutter @('pub','get') | Out-Null

if (-not $SkipCodegen) {
  # build_runner (Retrofit/json_serializable/Hive)
  Write-Info "Running code generation (build_runner)..."
  # Use 'dart' rather than 'flutter packages pub run' for speed and to avoid extra logs
  Invoke-Tool dart @('run','build_runner','build','--delete-conflicting-outputs') | Out-Null
  Write-Ok "Codegen completed."
} else {
  Write-Warn "Skipping code generation by request."
}

# -- Build --------------------------------------------------------------------
$defines = @("--dart-define=BASE_URL=$BaseUrl")
foreach ($d in $ExtraDefine) {
  if (-not ($d -match '^\w+=.*$')) {
    Write-Warn "Ignoring invalid define (expected KEY=VALUE): $d"
    continue
  }
  $defines += "--dart-define=$d"
}

$buildArgs = @('build','apk')
if ($Release) {
  $buildArgs += '--release'
} else {
  $buildArgs += '--debug'
}

$buildNameArgs = @()
if ($BuildName)   { $buildNameArgs += @('--build-name', $BuildName) }
if ($BuildNumber) { $buildNameArgs += @('--build-number', $BuildNumber) }

$buildArgs += $buildNameArgs
$buildArgs += $defines

Write-Info "Starting Flutter build..."
Invoke-Tool flutter $buildArgs | Out-Null
Write-Ok "Flutter build completed."

# -- Locate APK ----------------------------------------------------------------
$apkDir = Join-Path $ProjectPath 'build\app\outputs\flutter-apk'
$debugApk   = Join-Path $apkDir 'app-debug.apk'
$releaseApk = Join-Path $apkDir 'app-release.apk'

$apkPath = $null
if ($Release) {
  if (Test-Path -LiteralPath $releaseApk) { $apkPath = $releaseApk }
} else {
  if (Test-Path -LiteralPath $debugApk) { $apkPath = $debugApk }
}

if (-not $apkPath) {
  Write-Warn "Expected APK not found in $apkDir. Listing directory for clues:"
  if (Test-Path -LiteralPath $apkDir) {
    Get-ChildItem -LiteralPath $apkDir -Recurse | Format-Table -AutoSize
  } else {
    Write-Warn "Output directory missing: $apkDir"
  }
  throw "APK not found. Check build logs above."
}

Write-Ok "APK ready: $apkPath"

# -- Optional install -----------------------------------------------------------
if ($Install) {
  Write-Info "Attempting to install APK via adb..."
  # Ensure adb sees devices
  Invoke-Tool adb @('devices') -AllowFail | Out-Null

  $adbArgs = @('install','-r', $apkPath)
  if ($DeviceId) {
    $adbArgs = @('-s', $DeviceId) + $adbArgs
  }
  $code = Invoke-Tool adb $adbArgs -AllowFail
  if ($code -eq 0) {
    Write-Ok "Installed successfully."
  } else {
    Write-Warn "adb install failed (exit code $code). You may need to enable USB debugging or use a different device id."
  }
}

# -- Optional open folder ------------------------------------------------------
if ($OpenFolder) {
  Write-Info "Opening output folder in Explorer..."
  Invoke-Item -LiteralPath (Split-Path -Parent $apkPath)
}

Write-Host ""
Write-Ok "Done."
Write-Host " - Project : $ProjectPath"
Write-Host " - Variant : $(if ($Release) { 'release' } else { 'debug' })"
Write-Host " - BASE_URL: $BaseUrl"
Write-Host " - APK     : $apkPath"
