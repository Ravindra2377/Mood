# Start Postgres container and run migrations
# Usage: run this script from the backend folder in PowerShell

param()

Write-Output "Starting postgres container..."
docker compose up -d db

Write-Output "Waiting for postgres to accept connections..."
for ($i=0; $i -lt 60; $i++) {
    try {
        docker compose exec db pg_isready -U mh_user -d mh_db | Out-Null
        if ($LASTEXITCODE -eq 0) { Write-Output 'postgres ready'; break }
    } catch { }
    Start-Sleep -Seconds 1
}

Write-Output "Running alembic migrations inside web container..."
docker compose run --rm web python -m alembic upgrade head

Write-Output "Starting web service..."
docker compose up -d --build web

Write-Output "Done. Web service should be available at http://127.0.0.1:8000"
