import os
from fastapi.testclient import TestClient

# Force test DB so this script runs the same as pytest
os.environ['DATABASE_URL'] = 'sqlite:///./test_db.sqlite3'

from app.main import app, engine
from app.models import Base

# ensure schema exists
Base.metadata.create_all(bind=engine)

c = TestClient(app)
resp = c.post('/api/auth/signup', json={'email': 'debug_user@example.com', 'password': 'pw123'})
print('STATUS', resp.status_code)
try:
    print('JSON:', resp.json())
except Exception:
    print('TEXT:', resp.text)
