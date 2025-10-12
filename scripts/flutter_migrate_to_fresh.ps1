<#
.SYNOPSIS
  Automate migrating an existing Flutter app into a fresh Flutter project and building the APK.

.DESCRIPTION
  This script performs a safe migration of your Flutter app code into a newly created Flutter project
  to ensure Gradle/Android tooling is clean and aligned with the Flutter stable toolchain.

  Steps performed:
    1) Optional backup (zip) of the existing Flutter project (Dart code, assets, pubspec).
    2) Create a new fresh Flutter project at the specified destination path.
    3) Copy selected content (lib/, assets/, pubspec.yaml, analysis_options.yaml) into the fresh project.
    4) flutter pub get, optional build_runner code generation.
    5) Build debug or release APK with a required backend BASE_URL passed via --dart-define.
    6) Optional install of the APK on a connected Android device via adb.

.PARAMETER SourcePath
  Path to the existing Flutter project (the one to migrate). Default resolves to ../soul relative to this script.

.PARAMETER DestinationPath
  Path where the fresh Flutter project will be created. Default resolves to ../soul_fresh relative to this script.

.PARAMETER BaseUrl
  Backend base URL (required). Passed to Flutter via --dart-define=BASE_URL=<value>.

.PARAMETER Release
  Build a release APK (otherwise debug).

.PARAMETER SkipCodegen
  Skip build_runner code generation.

.PARAMETER Force
  If DestinationPath exists, delete it before creating the fresh project.

.PARAMETER Backup
  Create a zip backup of SourcePath key contents before migration. The backup is saved next to the script by default.

.PARAMETER BackupPath
  Optional explicit path for the backup zip file.

.PARAMETER AddJsonSerializable
  Attempt to add a compatible dev dependency json_serializable:^6.8.0 before running build_runner.

.PARAMETER Install
  After building, install the APK to a connected Android device using adb.

.PARAMETER DeviceId
  Optional device ID for adb -s parameter.

.PARAMETER CopyAnalysisOptions
  Copy analysis_options.yaml if it exists in the SourcePath.

.PARAMETER CopyAdditional
  Additional relative paths (from SourcePath) to copy into the fresh project root (e.g. ["assets/icons","assets/images"]).

.EXAMPLE
  # Migrate from ../soul to ../soul_fresh and build a debug APK against staging:
  .\flutter_migrate_to_fresh.ps1 -BaseUrl https://api-staging.soulapp.app -Backup

.EXAMPLE
  # Migrate and build a release APK against production, then install:
  .\flutter_migrate_to_fresh.ps1 -Release -BaseUrl https://api.soulapp.app -Install

.NOTES
  Requirements: Flutter SDK (flutter, dart), Android SDK (optional for adb install), PowerShell 5+.
#>

[CmdletBinding()]
param(
  [string]$SourcePath = (Join-Path -Path (Split-Path -Parent $PSCommandPath) -ChildPath "..\soul"),
  [string]$DestinationPath = (Join-Path -Path (Split-Path -Parent $PSCommandPath) -ChildPath "..\soul_fresh"),

  [Parameter(Mandatory = $true)]
  [string]$BaseUrl,

  [switch]$Release,
  [switch]$SkipCodegen,
  [switch]$Force,
  [switch]$Backup,
  [string]$BackupPath,
  [switch]$AddJsonSerializable,
  [switch]$Install,
  [string]$DeviceId,

  [switch]$CopyAnalysisOptions,
  [string[]]$CopyAdditional = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Info($msg) { Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Warn($msg) { Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-Err($msg)  { Write-Host "[ERR ] $msg" -ForegroundColor Red }
function Write-Ok($msg)   { Write-Host "[ OK ] $msg" -ForegroundColor Green }

function Assert-Command([string]$name) {
  if (-not (Get-Command $name -ErrorAction SilentlyContinue)) {
    throw "Required command not found: $name. Ensure it is installed and on PATH."
  }
}

function Resolve-FullPath([string]$p) {
  $rp = Resolve-Path -LiteralPath $p -ErrorAction SilentlyContinue
  if ($rp) { return $rp.Path }
  return [IO.Path]::GetFullPath($p)
}

function Invoke-Tool([string]$Exe, [string[]]$Args, [switch]$AllowFail) {
  Write-Info "$Exe $($Args -join ' ')"
  $psi = New-Object System.Diagnostics.ProcessStartInfo
  $psi.FileName = $Exe
  $Args | ForEach-Object { [void]$psi.ArgumentList.Add($_) }
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

function Test-DirNotEmpty([string]$path) {
  return (Test-Path -LiteralPath $path) -and ((Get-ChildItem -LiteralPath $path -Force | Measure-Object).Count -gt 0)
}

function Safe-Remove([string]$path) {
  if (Test-Path -LiteralPath $path) {
    Write-Warn "Removing existing: $path"
    Remove-Item -LiteralPath $path -Recurse -Force -ErrorAction Stop
  }
}

function Copy-Tree([string]$src, [string]$dst) {
  if (-not (Test-Path -LiteralPath $src)) {
    Write-Warn "Source not found, skipping copy: $src"
    return
  }
  New-Item -ItemType Directory -Path (Split-Path -Parent $dst) -Force | Out-Null
  if ((Get-Item $src).PSIsContainer) {
    New-Item -ItemType Directory -Path $dst -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $src '*') -Destination $dst -Recurse -Force -ErrorAction Stop
  } else {
    Copy-Item -LiteralPath $src -Destination $dst -Force -ErrorAction Stop
  }
  Write-Ok "Copied: $src -> $dst"
}

function New-Zip([string]$sourceRoot, [string]$zipPath, [string[]]$relPaths) {
  Add-Type -AssemblyName System.IO.Compression.FileSystem
  $zipDir = Split-Path -Parent $zipPath
  if (-not (Test-Path -LiteralPath $zipDir)) {
    New-Item -ItemType Directory -Path $zipDir -Force | Out-Null
  }
  if (Test-Path -LiteralPath $zipPath) {
    Remove-Item -LiteralPath $zipPath -Force
  }
  $zip = [System.IO.Compression.ZipFile]::Open($zipPath, 'Create')
  try {
    foreach ($rel in $relPaths) {
      $full = Join-Path $sourceRoot $rel
      if (-not (Test-Path -LiteralPath $full)) { continue }
      $item = Get-Item -LiteralPath $full
      if ($item.PSIsContainer) {
        $files = Get-ChildItem -LiteralPath $full -Recurse -File
        foreach ($f in $files) {
          $entryName = [IO.Path]::GetRelativePath($sourceRoot, $f.FullName)
          [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $f.FullName, $entryName, 'Optimal') | Out-Null
        }
      } else {
        $entryName = [IO.Path]::GetRelativePath($sourceRoot, $item.FullName)
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $item.FullName, $entryName, 'Optimal') | Out-Null
      }
    }
  } finally {
    $zip.Dispose()
  }
  Write-Ok "Backup created: $zipPath"
}

# --- Preconditions ------------------------------------------------------------
Assert-Command flutter
Assert-Command dart
if ($Install) { Assert-Command adb }

$SourcePath      = Resolve-FullPath $SourcePath
$DestinationPath = Resolve-FullPath $DestinationPath

Write-Info "SourcePath      : $SourcePath"
Write-Info "DestinationPath : $DestinationPath"
Write-Info "Mode            : $(if ($Release) { 'release' } else { 'debug' })"
Write-Info "BASE_URL        : $BaseUrl"

if (-not (Test-Path -LiteralPath $SourcePath)) {
  throw "SourcePath not found: $SourcePath"
}
if (-not (Test-Path -LiteralPath (Join-Path $SourcePath 'lib'))) {
  throw "SourcePath doesn't look like a Flutter project (missing 'lib' folder): $SourcePath"
}
if (-not (Test-Path -LiteralPath (Join-Path $SourcePath 'pubspec.yaml'))) {
  throw "SourcePath missing pubspec.yaml: $SourcePath"
}

# --- Optional backup ----------------------------------------------------------
if ($Backup) {
  $defaultBackupName = "flutter_migration_backup_{0:yyyyMMdd_HHmmss}.zip" -f (Get-Date)
  $backupOut = $(if ($BackupPath) { Resolve-FullPath $BackupPath } else { Join-Path -Path (Split-Path -Parent $PSCommandPath) -ChildPath $defaultBackupName })
  Write-Info "Creating backup from SourcePath to: $backupOut"
  $backupRel = @('lib', 'assets', 'pubspec.yaml', 'analysis_options.yaml')
  # Include additional if specified
  foreach ($rel in $CopyAdditional) {
    if ($backupRel -notcontains $rel) { $backupRel += $rel }
  }
  New-Zip -sourceRoot $SourcePath -zipPath $backupOut -relPaths $backupRel
}

# --- Prepare destination: delete if Force, otherwise must be absent ----------
if (Test-Path -LiteralPath $DestinationPath) {
  if (-not $Force) {
    throw "DestinationPath already exists: $DestinationPath. Use -Force to delete it and continue."
  }
  Safe-Remove $DestinationPath
}

# --- Create fresh Flutter project --------------------------------------------
Write-Info "Creating fresh Flutter project..."
$parent = Split-Path -Parent $DestinationPath
$newName = Split-Path -Leaf $DestinationPath
if (-not (Test-Path -LiteralPath $parent)) {
  New-Item -ItemType Directory -Path $parent -Force | Out-Null
}
Invoke-Tool flutter @('create','-t','app', $DestinationPath) | Out-Null
Write-Ok "Fresh Flutter project created at: $DestinationPath"

# --- Copy project content (lib, assets, pubspec, analysis options, additional)
# lib/
$srcLib = Join-Path $SourcePath 'lib'
$dstLib = Join-Path $DestinationPath 'lib'
Safe-Remove $dstLib
Copy-Tree $srcLib $dstLib

# assets/
$srcAssets = Join-Path $SourcePath 'assets'
$dstAssets = Join-Path $DestinationPath 'assets'
if (Test-Path -LiteralPath $srcAssets) {
  Safe-Remove $dstAssets
  Copy-Tree $srcAssets $dstAssets
} else {
  Write-Warn "No assets/ directory found in SourcePath (skipping)."
}

# pubspec.yaml
$srcPubspec = Join-Path $SourcePath 'pubspec.yaml'
$dstPubspec = Join-Path $DestinationPath 'pubspec.yaml'
Copy-Tree $srcPubspec $dstPubspec

# analysis_options.yaml (optional)
if ($CopyAnalysisOptions) {
  $srcAnalysis = Join-Path $SourcePath 'analysis_options.yaml'
  if (Test-Path -LiteralPath $srcAnalysis) {
    $dstAnalysis = Join-Path $DestinationPath 'analysis_options.yaml'
    Copy-Tree $srcAnalysis $dstAnalysis
  } else {
    Write-Warn "analysis_options.yaml not found in SourcePath (skipping)."
  }
}

# Additional relative paths (optional)
foreach ($rel in $CopyAdditional) {
  $srcExtra = Join-Path $SourcePath $rel
  $dstExtra = Join-Path $DestinationPath $rel
  Copy-Tree $srcExtra $dstExtra
}

# --- Dependencies -------------------------------------------------------------
Push-Location $DestinationPath
try {
  Write-Info "Running: flutter pub get"
  Invoke-Tool flutter @('pub','get') | Out-Null

  if ($AddJsonSerializable) {
    Write-Info "Ensuring json_serializable dev dependency (^6.8.0) for code generation..."
    Invoke-Tool dart @('pub','add','--dev','json_serializable:^6.8.0') -AllowFail | Out-Null
    # Re-run pub get in case changes applied
    Invoke-Tool flutter @('pub','get') | Out-Null
  }

  if (-not $SkipCodegen) {
    Write-Info "Running code generation (build_runner)..."
    $codegenExit = 0
    try {
      $codegenExit = Invoke-Tool dart @('run','build_runner','build','--delete-conflicting-outputs') -AllowFail
    } catch {
      $codegenExit = 1
    }
    if ($codegenExit -ne 0) {
      Write-Warn "build_runner failed. Attempting to add json_serializable:^6.8.0 and retry..."
      try {
        Invoke-Tool dart @('pub','add','--dev','json_serializable:^6.8.0') -AllowFail | Out-Null
        Invoke-Tool flutter @('pub','get') | Out-Null
        Invoke-Tool dart @('run','build_runner','build','--delete-conflicting-outputs') | Out-Null
        Write-Ok "Codegen succeeded after adjusting dev dependency."
      } catch {
        Write-Err "Code generation failed despite retry. You may need to adjust your dependencies manually."
        throw
      }
    } else {
      Write-Ok "Codegen completed."
    }
  } else {
    Write-Warn "Skipping code generation as requested."
  }

  # --- Build APK -------------------------------------------------------------
  $defines = @("--dart-define=BASE_URL=$BaseUrl")
  $buildArgs = @('build','apk')
  if ($Release) { $buildArgs += '--release' } else { $buildArgs += '--debug' }
  $buildArgs += $defines

  Write-Info "Building Flutter APK..."
  Invoke-Tool flutter $buildArgs | Out-Null
  Write-Ok "Flutter build completed."

  # Locate APK
  $apkDir = Join-Path $DestinationPath 'build\app\outputs\flutter-apk'
  $debugApk   = Join-Path $apkDir 'app-debug.apk'
  $releaseApk = Join-Path $apkDir 'app-release.apk'
  $apkPath = $null
  if ($Release) {
    if (Test-Path -LiteralPath $releaseApk) { $apkPath = $releaseApk }
  } else {
    if (Test-Path -LiteralPath $debugApk) { $apkPath = $debugApk }
  }

  if (-not $apkPath) {
    Write-Warn "Expected APK not found in $apkDir. Contents:"
    if (Test-Path -LiteralPath $apkDir) {
      Get-ChildItem -LiteralPath $apkDir -Recurse | Format-Table -AutoSize
    }
    throw "APK not found. Check build logs."
  }

  Write-Ok "APK produced: $apkPath"

  if ($Install) {
    Write-Info "Installing APK via adb..."
    Invoke-Tool adb @('devices') -AllowFail | Out-Null
    $adbArgs = @('install','-r', $apkPath)
    if ($DeviceId) {
      $adbArgs = @('-s', $DeviceId) + $adbArgs
    }
    $code = Invoke-Tool adb $adbArgs -AllowFail
    if ($code -eq 0) {
      Write-Ok "Installed successfully."
    } else {
      Write-Warn "adb install failed (exit code $code). Ensure USB debugging is enabled or specify -DeviceId."
    }
  }

} finally {
  Pop-Location
}

# --- Summary -----------------------------------------------------------------
Write-Host ""
Write-Ok "Migration complete."
Write-Host " - Source       : $SourcePath"
Write-Host " - Destination  : $DestinationPath"
Write-Host " - Mode         : $(if ($Release) { 'release' } else { 'debug' })"
Write-Host " - BASE_URL     : $BaseUrl"
Write-Host " - Next steps   : Open the project in your IDE, continue development in the fresh structure."
