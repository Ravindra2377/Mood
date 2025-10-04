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
