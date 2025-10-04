import os
import sys
from fastapi.testclient import TestClient

# ensure current dir is on path so 'app' package is importable when run here
sys.path.insert(0, os.getcwd())

# use same test DB as pytest
os.environ.setdefault('DATABASE_URL', 'sqlite:///./test_db.sqlite3')

from app.main import app, engine
from app.models import Base

# ensure tables exist
Base.metadata.create_all(bind=engine)

client = TestClient(app)
resp = client.post('/api/auth/signup', json={'email': 'debug_user@example.com', 'password': 'pw'})
print('status', resp.status_code)
try:
    print('json', resp.json())
except Exception:
    print('text', resp.text)
