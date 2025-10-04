# PowerShell helper: apply Alembic migrations to DATABASE_URL and run pytest
# Usage: Open PowerShell in this folder and run: .\apply_migrations_and_test.ps1

# Force test DB for safety
$env:DATABASE_URL = 'sqlite:///./test_db.sqlite3'

Write-Output "Applying Alembic migrations to $env:DATABASE_URL"
python -m alembic -c alembic.ini upgrade head
$exitCode = $LASTEXITCODE
if ($exitCode -ne 0) {
    Write-Error "Alembic upgrade failed with exit code $exitCode"
    exit $exitCode
}

Write-Output "Running pytest"
python -m pytest -q
exit $LASTEXITCODE
