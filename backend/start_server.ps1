<#
start_server.ps1
Starts the FastAPI backend server using uvicorn with SQLite database.
Run from PowerShell:
  .\start_server.ps1
#>

$ErrorActionPreference = 'Stop'
Set-Location -Path $PSScriptRoot

Write-Host "`n==== Starting FastAPI Backend Server ====`n" -ForegroundColor Cyan

# Set environment variables
$env:DATABASE_URL = "sqlite:///./mh.db"
$env:ENABLE_BACKGROUND_WORKER = "False"
$env:DEV_MODE = "True"

# Activate virtual environment and start server
$venvPython = Join-Path $PSScriptRoot ".venv\Scripts\python.exe"

if (-not (Test-Path $venvPython)) {
    Write-Host "ERROR: Virtual environment not found at $venvPython" -ForegroundColor Red
    Write-Host "Please create a virtual environment first:" -ForegroundColor Yellow
    Write-Host "  python -m venv .venv" -ForegroundColor Yellow
    Write-Host "  .\.venv\Scripts\pip install -r requirements.txt" -ForegroundColor Yellow
    exit 1
}

Write-Host "Using Python: $venvPython" -ForegroundColor Green
Write-Host "Database: SQLite (mh.db)" -ForegroundColor Green
Write-Host "Server URL: http://localhost:8000" -ForegroundColor Green
Write-Host "API Docs: http://localhost:8000/docs" -ForegroundColor Green
Write-Host "`nPress Ctrl+C to stop the server`n" -ForegroundColor Yellow

& $venvPython -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
