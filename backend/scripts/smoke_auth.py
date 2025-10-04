from fastapi.testclient import TestClient
import sys
from pathlib import Path
import os

# Ensure backend folder is on sys.path so 'app' package imports work when running the script
script_dir = Path(__file__).resolve().parent
project_root = script_dir.parent
sys.path.insert(0, str(project_root))

# Force test DATABASE_URL to a file-backed sqlite so we don't attempt to connect to Postgres
os.environ.setdefault('DATABASE_URL', 'sqlite:///./test_db.sqlite3')

from app.main import app
# ensure all tables exist in the test DB (in case migrations haven't been applied)
try:
    from app.models import Base
    from app.main import engine
    Base.metadata.create_all(bind=engine)
except Exception as e:
    print('Warning: could not create all tables:', e)

client = TestClient(app)

def fail(msg):
    print('FAIL:', msg)
    sys.exit(1)

def ok(msg):
    print('OK:', msg)

def run():
    import time
    email = f'smoke_user_{int(time.time())}@example.com'
    pw = 'smokepw'

    print('Using email:', email)
    # signup
    r = client.post('/api/auth/signup', json={'email': email, 'password': pw})
    if r.status_code != 200:
        fail(f'signup failed: {r.status_code} {r.text}')
    ok('signup')

    # login
    t = client.post('/api/auth/token', data={'username': email, 'password': pw})
    print('token resp status:', t.status_code)
    print('token resp text:', t.text)
    if t.status_code != 200:
        fail(f'login failed: {t.status_code} {t.text}')
    body = t.json()
    if 'access_token' not in body or 'refresh_token' not in body:
        fail(f'tokens missing on login; body: {body}')
    access = body['access_token']
    refresh = body['refresh_token']
    ok('login and tokens')

    # request verification
    rv = client.post('/api/auth/verify', params={'email': email})
    if rv.status_code != 200:
        fail('verify request failed')
    ok('verify request')

    # exchange refresh (rotation)
    rf = client.post('/api/auth/refresh', json={'old_refresh_token': refresh})
    if rf.status_code != 200:
        fail(f'refresh failed: {rf.status_code} {rf.text}')
    nb = rf.json()
    if 'access_token' not in nb or 'refresh_token' not in nb:
        fail('refresh response missing tokens')
    ok('refresh rotation')

    # logout revoke
    lo = client.post('/api/auth/logout', json={'refresh_token': nb['refresh_token']})
    if lo.status_code != 200:
        fail('logout failed')
    ok('logout/revoke')

    # try to refresh with revoked token
    r2 = client.post('/api/auth/refresh', json={'old_refresh_token': nb['refresh_token']})
    if r2.status_code == 200:
        fail('revoked token still allowed')
    ok('revoked token rejected')

    print('\nALL SMOKE TESTS PASSED')

if __name__ == '__main__':
    run()
