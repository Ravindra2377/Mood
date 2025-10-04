from pathlib import Path
import sys
import os
project_root = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(project_root))
os.environ.setdefault('DATABASE_URL', 'sqlite:///./test_db.sqlite3')

from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

email = sys.argv[1] if len(sys.argv) > 1 else 'debug@example.com'
pw = sys.argv[2] if len(sys.argv) > 2 else 'pw'

resp = client.post('/api/auth/token', data={'username': email, 'password': pw})
print('status', resp.status_code)
try:
    print('json:', resp.json())
except Exception:
    print('text:', resp.text)
