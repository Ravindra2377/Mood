# SOUL — Backend

This repository contains the backend for the SOUL app (FastAPI-based prototype). It provides endpoints for mood tracking, journals, community, crisis detection, analytics, and admin utilities.

Quick start (development)

1. Create a Python virtual environment and install pinned dependencies:

   ```powershell
   python -m venv .venv
   .\.venv\Scripts\Activate.ps1
   pip install -r requirements.txt
   ```

2. Set environment variables (see `.env.example`) or create a `.env` file in the `backend/` folder.

3. Run the app with Uvicorn:

   ```powershell
   cd backend
   uvicorn app.main:app --reload
   ```

Configuration

- `DATABASE_URL` — SQLAlchemy DB URL (default sqlite:///./mh.db)
- `KMS_KEY_ID` — AWS KMS KeyId to enable envelope encryption of sensitive fields (optional)
- `DATA_ENCRYPTION_KEY` — optional fallback Fernet key for local encryption when KMS not configured
- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION` — credentials for S3/KMS operations
- `SEGMENT_WRITE_KEY` — optional Segment write key for analytics export
- `DATA_RETENTION_DAYS` — if set, retention job will purge older data

Security notes

- Do NOT commit secrets. Use GitHub Secrets / environment variables in CI and your deployment environment.
- For production HIPAA compliance: use AWS KMS, secure logging, and a managed queue (Celery/RQ). The repo includes a KMS envelope encryption helper.

Developer notes

- Tests: run `python -m pytest -q` from the `backend` folder.
- To rotate journal encryption keys (KMS), use the `app.services.envelope_crypto.rotate_journal_keys` function.

Key rotation CLI

The repository includes a helper CLI to rotate journal entry encryption keys:

Python usage (dry-run by default):

```powershell
cd backend
python .\scripts\rotate_keys.py --kms-key-id <KMS_KEY_ID> --batch 100
```

To actually apply changes, pass `--commit --yes` (the `--yes` flag is required as a safety confirmation):

```powershell
python .\scripts\rotate_keys.py --kms-key-id <KMS_KEY_ID> --batch 100 --commit --yes
```

PowerShell wrapper (Windows)

There's a wrapper that activates a local `.venv` (if present) and forwards arguments to the Python script:

```powershell
.\backend\scripts\rotate_keys.ps1 --kms-key-id <KMS_KEY_ID> --batch 100
```

Notes

- `--db-url` lets you override the `DATABASE_URL` for the run (useful for staging/test DBs).
- The CLI will report counts in dry-run mode and exit without changes unless `--commit --yes` are supplied.
# mh-ai-app backend

This is a minimal FastAPI backend prototype for the mental-health app. It includes user signup/login (JWT tokens) and mood tracking endpoints.

Development quickstart (Windows PowerShell):

```powershell
cd "d:/OneDrive/Desktop/Mood/backend"
python -m venv .venv; .\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```

API endpoints:
- POST /api/auth/signup
- POST /api/auth/login
- GET /api/moods (requires Authorization: Bearer <token>)
- POST /api/moods (requires Authorization)

## Running with Postgres (docker-compose)

1. Build and run the services:

	docker compose up --build

2. The web server will be available at http://localhost:8000 and Postgres at port 5432.

3. Environment variables:

	- `DATABASE_URL` can be set to `postgresql+psycopg2://mh_user:mh_pass@db:5432/mh_db` when using docker-compose.

4. Alembic migrations:

	If you change models, run migrations locally (from the backend dir):

	- python -m alembic revision --autogenerate -m "message"
	- python -m alembic upgrade head

Helper script (Windows PowerShell)
---------------------------------

There's a small helper script to start Postgres and run migrations on Windows:

```powershell
cd D:/OneDrive/Desktop/Mood/backend
.
\start_db_and_migrate.ps1
```

This will bring up the Postgres container, run alembic migrations inside the web container and start the web service.
