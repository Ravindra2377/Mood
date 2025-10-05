# Minimal PowerShell wrapper for rotate_keys.py
# Activates .venv if present and forwards all arguments to the Python rotation CLI.

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$backendDir = Resolve-Path (Join-Path $scriptDir '..')
Set-Location $backendDir

$venvActivate = Join-Path $backendDir '.venv\Scripts\Activate.ps1'
if (Test-Path $venvActivate) {
    Write-Host "Activating venv: $venvActivate"
    & $venvActivate
} else {
    Write-Host "No local venv found at $venvActivate - running system python"
}

# Forward all args to the Python CLI
$python = 'python'
if ($args.Count -gt 0) {
    & $python .\scripts\rotate_keys.py @args
} else {
    & $python .\scripts\rotate_keys.py
}
exit $LASTEXITCODE
