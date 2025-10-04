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
