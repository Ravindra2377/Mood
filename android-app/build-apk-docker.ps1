<#
  File: build-apk-docker.ps1
  Purpose: Build Android APK(s) inside Docker (no local SDK/Gradle needed) and extract artifacts.

  Requirements:
    - Docker Desktop running
    - This script lives in android-app/ next to Dockerfile.android

  Usage examples:
    # Build signed prod release (Option B) and extract APK
    .\build-apk-docker.ps1 -Variant prodRelease

    # Build prod debug
    .\build-apk-docker.ps1 -Variant prodDebug

    # Build all variants
    .\build-apk-docker.ps1 -Variant all

    # Force a clean image rebuild and pull base layers
    .\build-apk-docker.ps1 -Variant prodRelease -NoCache -Pull

    # Remove the intermediate Docker image(s) after extraction
    .\build-apk-docker.ps1 -Variant prodRelease -CleanImages
#>

[CmdletBinding()]
param(
  [Parameter(Mandatory = $false)]
  [ValidateSet('stagingDebug','prodDebug','prodRelease','all')]
  [string]$Variant = 'prodRelease',

  [Parameter(Mandatory = $false)]
  [string]$TagPrefix = 'soul-android-build',

  [Parameter(Mandatory = $false)]
  [switch]$NoCache,

  [Parameter(Mandatory = $false)]
  [switch]$Pull,

  [Parameter(Mandatory = $false)]
  [switch]$CleanImages
)


# Using PowerShell error handling; see $ErrorActionPreference below

$ErrorActionPreference = 'Stop'

# Resolve script directory (android-app/) and ensure Dockerfile.android exists
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Definition }
Set-Location $scriptDir

$dockerfilePath = Join-Path $scriptDir 'Dockerfile.android'
if (-not (Test-Path -LiteralPath $dockerfilePath)) {
  throw "Dockerfile.android not found at: $dockerfilePath`nMake sure you run this from android-app and that Dockerfile.android exists."
}

function Assert-Command([string]$Name) {
  if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
    throw "Required command not found: $Name. Ensure Docker Desktop is installed and the command is in PATH."
  }
}

Assert-Command docker

# Quick docker sanity
try {
  $null = docker version --format '{{.Server.Version}}' 2>$null
} catch {
  Write-Host "Docker doesn’t seem to be running. Please start Docker Desktop and try again." -ForegroundColor Yellow
  throw
}

# Build matrix
$Matrix = @{
  'stagingDebug' = @{
    BuildTask = ':app:assembleStagingDebug'
    InternalPaths = @('/app/app/build/outputs/apk/staging/debug/app-staging-debug.apk')
    OutFilePreferred = 'app-staging-debug.apk'
    Description = 'Staging Debug APK'
  }
  'prodDebug' = @{
    BuildTask = ':app:assembleProdDebug'
    InternalPaths = @('/app/app/build/outputs/apk/prod/debug/app-prod-debug.apk')
    OutFilePreferred = 'app-prod-debug.apk'
    Description = 'Production Debug APK'
  }
  'prodRelease' = @{
    BuildTask = ':app:assembleProdRelease'
    # Dockerfile.android auto-signs to app-prod-release.apk (Option B), but we still fall back to unsigned name if needed.
    InternalPaths = @(
      '/app/app/build/outputs/apk/prod/release/app-prod-release.apk',            # signed (preferred)
      '/app/app/build/outputs/apk/prod/release/app-prod-release-unsigned.apk'    # fallback
    )
    OutFilePreferred = 'app-prod-release.apk'
    OutFileFallback  = 'app-prod-release-unsigned.apk'
    Description = 'Production Release APK (signed in-container with debug-style key)'
  }
}

# Resolve which variants to build
$VariantsToBuild = if ($Variant -eq 'all') { @('stagingDebug','prodDebug','prodRelease') } else { @($Variant) }

# Output directory: android-app/dist-apk/<variant>/
$distRoot = Join-Path $scriptDir 'dist-apk'
New-Item -ItemType Directory -Force -Path $distRoot | Out-Null

$built = @()

foreach ($v in $VariantsToBuild) {
  if (-not $Matrix.ContainsKey($v)) {
    throw "Unknown variant: $v"
  }

  $spec = $Matrix[$v]
  $buildTask = $spec.BuildTask
  $tag = "${TagPrefix}:$v"

  Write-Host "=== Building variant: $v ($($spec.Description)) ===" -ForegroundColor Cyan
  Write-Host "Using build task: $buildTask" -ForegroundColor DarkCyan

  # Build args
  $buildArgs = @('build', '-f', $dockerfilePath, '--build-arg', "BUILD_TASK=$buildTask", '-t', $tag, $scriptDir)
  if ($NoCache) { $buildArgs = @('build', '--no-cache') + $buildArgs[1..($buildArgs.Length-1)] }
  if ($Pull)    { $buildArgs = @('build', '--pull') + $buildArgs[1..($buildArgs.Length-1)] }

  # docker build
  Write-Host "docker $($buildArgs -join ' ')" -ForegroundColor Gray
  docker @buildArgs

  # Create container
  $cid = (docker create $tag).Trim()
  if (-not $cid) {
    throw "Failed to create container from image tag: $tag"
  }

  try {
    # Prepare destination directory
    $outDir = Join-Path $distRoot $v
    New-Item -ItemType Directory -Force -Path $outDir | Out-Null

    # Try preferred internal paths in order
    $copied = $false
    $dstFile = $null

    foreach ($internal in $spec.InternalPaths) {
      $leaf = Split-Path -Path $internal -Leaf

      # Choose output filename: prefer explicit names; for prodRelease distinguish signed/unsigned
      if ($v -eq 'prodRelease') {
        if ($leaf -like '*-unsigned.apk') {
          $dstFile = Join-Path $outDir ($spec.OutFileFallback)
        } else {
          $dstFile = Join-Path $outDir ($spec.OutFilePreferred)
        }
      } else {
        $dstFile = Join-Path $outDir ($spec.OutFilePreferred)
      }

      Write-Host "Attempting to copy $internal -> $dstFile" -ForegroundColor Gray
      $copySucceeded = $true
      try {
        docker cp "${cid}:$internal" "$dstFile" 2>$null
      } catch {
        $copySucceeded = $false
      }

      if ($copySucceeded -and (Test-Path -LiteralPath $dstFile)) {
        $size = (Get-Item -LiteralPath $dstFile).Length
        Write-Host ("Extracted {0:N0} bytes to {1}" -f $size, $dstFile) -ForegroundColor Green
        $copied = $true
        break
      } else {
        Write-Host "Not found: $internal (continuing...)" -ForegroundColor Yellow
      }
    }

    if (-not $copied) {
      throw "No expected APK was found in the container for variant '$v'. Check the Docker build logs above for errors."
    }

    $built += [PSCustomObject]@{
      Variant = $v
      Output  = $dstFile
    }
  }
  finally {
    # Cleanup container always
    try { docker rm $cid | Out-Null } catch { }
    if ($CleanImages) {
      try { docker rmi $tag | Out-Null } catch { }
    }
  }
}

Write-Host ""
Write-Host "=== Build complete ===" -ForegroundColor Cyan
foreach ($b in $built) {
  $p = Resolve-Path $b.Output
  Write-Host (" - {0}: {1}" -f $b.Variant, $p) -ForegroundColor White
}

Write-Host ""
Write-Host "You can now share or install the APK(s):" -ForegroundColor Cyan
Write-Host " - Upload to Drive/Dropbox and open link on device, or" -ForegroundColor White
Write-Host " - Use ADB: adb install -r <path-to-apk>" -ForegroundColor White
