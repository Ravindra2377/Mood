import os
import sys
import json
from pathlib import Path

# ensure tests use the sqlite file DB
os.environ.setdefault('DATABASE_URL', 'sqlite:///./test_db.sqlite3')

# remove old DB for a clean run
dbfile = Path('./test_db.sqlite3')
if dbfile.exists():
    dbfile.unlink()

# ensure backend root is on sys.path so 'app' package can be imported
backend_root = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(backend_root))

from app.main import app
from fastapi.testclient import TestClient
from app.models import Base
from app.main import engine

# create tables (TestClient may not trigger startup in this script)
Base.metadata.create_all(bind=engine)

client = TestClient(app)

payload = {'email': 'debug_user@example.com', 'password': 'pwdebug'}
resp = client.post('/api/auth/signup', json=payload)
print('STATUS', resp.status_code)
try:
    print('JSON:', resp.json())
except Exception:
    print('TEXT:', resp.text)
