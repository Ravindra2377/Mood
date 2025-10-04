<#
fix_docker_and_start.ps1

This script tries to detect and start Docker Desktop (if installed), restarts Docker services if needed,
and then runs start_db_and_migrate.ps1 to bring up Postgres and run migrations.

Run this script from PowerShell as Administrator if possible:
  Set-Location 'D:\OneDrive\Desktop\Mood\backend'
  .\fix_docker_and_start.ps1

If it fails, copy the output and paste it here so I can diagnose further.
#>

param()

function Write-Header($s){ Write-Output "`n==== $s ==== `n" }

Set-Location -Path (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)

Write-Header 'Check docker availability'
try{
    docker version | Out-Null
    Write-Output 'Docker CLI is available.'
} catch {
    Write-Output 'Docker CLI appears unavailable or Docker engine is not running.'
}

# Try docker info to see if engine responds
$dockerOk = $false
try{
    docker info > $null 2>&1
    if ($LASTEXITCODE -eq 0) { $dockerOk = $true; Write-Output 'Docker engine is responding.' }
} catch { }

if (-not $dockerOk) {
    Write-Header 'Attempt: Start Docker Desktop (if installed)'
    # Try common install paths
    $candidates = @(
        "$Env:ProgramFiles\Docker\Docker\Docker Desktop.exe",
        "$Env:ProgramFiles(x86)\Docker\Docker\Docker Desktop.exe",
        "$Env:ProgramFiles\Docker\Docker Desktop.exe",
        "$Env:ProgramFiles(x86)\Docker\Docker Desktop.exe"
    )
    $found = $null
    foreach ($p in $candidates){ if (Test-Path $p) { $found = $p; break } }
    if ($found) {
        Write-Output "Found Docker Desktop at: $found"
        try{
            Start-Process -FilePath $found -ArgumentList '--quiet' -ErrorAction Stop
            Write-Output 'Launched Docker Desktop -- waiting up to 60s for engine to come up...'
            for ($i=0; $i -lt 60; $i++){
                Start-Sleep -Seconds 1
                docker info > $null 2>&1
                if ($LASTEXITCODE -eq 0){ $dockerOk = $true; Write-Output 'Docker engine is responding.'; break }
            }
        } catch {
            Write-Output "Could not start Docker Desktop: $($_.Exception.Message)"
        }
    } else {
        Write-Output 'Docker Desktop executable not found in common Program Files locations.'
    }
}

if (-not $dockerOk) {
    Write-Header 'Attempt: Restart Docker services (requires admin)'
    $services = @('com.docker.service','Docker Desktop Service','docker')
    foreach ($s in $services){
        try{
            $svc = Get-Service -Name $s -ErrorAction SilentlyContinue
            if ($svc) {
                Write-Output "Restarting service: $s"
                Restart-Service -Name $s -Force -ErrorAction Stop
                Start-Sleep -Seconds 3
                docker info > $null 2>&1
                if ($LASTEXITCODE -eq 0){ $dockerOk = $true; Write-Output 'Docker engine is responding after service restart.'; break }
            } else {
                Write-Output "Service not found: $s"
            }
                } catch {
            Write-Output ("Failed to restart service {0}: {1}" -f $s, ${_}.Exception.Message)
        }
    }
}

if (-not $dockerOk) {
    Write-Header 'Attempt: WSL shutdown (if using WSL2 backend)'
    try{
        wsl --shutdown
        Start-Sleep -Seconds 2
        for ($i=0; $i -lt 20; $i++){
            docker info > $null 2>&1
            if ($LASTEXITCODE -eq 0){ $dockerOk = $true; Write-Output 'Docker engine is responding after WSL shutdown.'; break }
            Start-Sleep -Seconds 1
        }
        } catch {
        Write-Output 'WSL not available or wsl command failed.'
    }
}

if (-not $dockerOk) {
    Write-Header 'Diagnostics: Docker is still not responding. Collecting diagnostic info'
    try{ docker version } catch { Write-Output 'docker version failed' }
    try{ docker info } catch { Write-Output 'docker info failed' }
    Write-Output 'List Docker-related services:'
    Get-Service *docker* | Format-Table -AutoSize
    Write-Output 'WSL distributions (if present):'
    try{ wsl -l -v } catch { Write-Output 'wsl -l -v failed or WSL not installed' }

    Write-Header 'Please ensure Docker Desktop is running (start it from Start Menu) and re-run this script.'
    exit 1
}

Write-Header 'Docker is available — proceeding to start DB and run migrations'
# Call existing helper
$script = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Definition) 'start_db_and_migrate.ps1'
if (Test-Path $script){
    & $script
} else {
    Write-Output "Helper script not found: $script"
}

Write-Header 'Finished'

