import os
from fastapi.testclient import TestClient

# Mirror tests' conftest: use a file-backed sqlite DB for deterministic test behavior
os.environ.setdefault('DATABASE_URL', 'sqlite:///./test_db.sqlite3')

from app.main import app

c = TestClient(app)
r = c.post('/api/auth/signup', json={'email': 'debug@example.com', 'password': 'pw'})
print('status', r.status_code)
try:
    print('json:', r.json())
except Exception:
    print('text:', r.text)
