from fastapi.testclient import TestClient
import sys
from pathlib import Path
import os

project_root = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(project_root))
os.environ.setdefault('DATABASE_URL', 'sqlite:///./test_db.sqlite3')

from app.main import app
from app.models import Base
from app.main import engine

# Ensure test DB schema exists (create_all will add any new columns/tables)
# For test runs we drop and recreate to ensure the schema matches current models
# (this is safe for the test DB file used only in CI/dev)
Base.metadata.drop_all(bind=engine)
Base.metadata.create_all(bind=engine)

client = TestClient(app)

def fail(msg):
    print('FAIL:', msg)
    sys.exit(1)

def ok(msg):
    print('OK:', msg)

def run():
    email = f'smoke_profile_{int(Path().stat().st_mtime % 100000)}@example.com'
    pw = 'pw'
    # signup
    r = client.post('/api/auth/signup', json={'email': email, 'password': pw})
    if r.status_code != 200:
        fail('signup failed')
    ok('signup')
    t = client.post('/api/auth/token', data={'username': email, 'password': pw})
    if t.status_code != 200:
        fail('token failed')
    token = t.json()['access_token']
    headers = {'Authorization': f'Bearer {token}'}

    # get profile
    r = client.get('/api/profile', headers=headers)
    if r.status_code != 200:
        fail('get profile failed')
    ok('get profile')

    upd = {'consent_privacy': True, 'notify_email': True, 'notify_push': True, 'display_name': 'Smokey'}
    p = client.patch('/api/profile', json=upd, headers=headers)
    print('patch status', p.status_code)
    print('patch body', p.text)
    if p.status_code != 200:
        fail('patch profile failed')
    ok('patch profile')

    a = client.get('/api/profile/audits', headers=headers)
    if a.status_code != 200:
        fail('get audits failed')
    audits = a.json()
    if not any(x['field'] == 'consent_privacy' for x in audits):
        fail('consent audit missing')
    ok('consent audit present')

    # export JSON
    ex = client.get('/api/profile/audits/export', headers=headers)
    if ex.status_code != 200:
        fail('export json failed')
    json_rows = ex.json()
    if not isinstance(json_rows, list) or len(json_rows) == 0:
        fail('export json empty')
    ok('export json')

    # export CSV
    ex2 = client.get('/api/profile/audits/export?format=csv', headers=headers)
    if ex2.status_code != 200:
        fail('export csv failed')
    if 'id,field,old_value' not in ex2.text:
        fail('export csv invalid')
    ok('export csv')

    print('\nPROFILE SMOKE OK')

if __name__ == '__main__':
    run()
