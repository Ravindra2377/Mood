import os
import pytest
from fastapi.testclient import TestClient

os.environ.setdefault('DATABASE_URL', 'sqlite:///./test_db.sqlite3')

from app.main import app


@pytest.fixture
def client():
    return TestClient(app)


def signup_and_token(client, email, pw='pw'):
    r = client.post('/api/auth/signup', json={'email': email, 'password': pw})
    assert r.status_code == 200
    t = client.post('/api/auth/token', data={'username': email, 'password': pw})
    assert t.status_code == 200
    return t.json()['access_token']


def test_profile_update_and_audit(client):
    email = 'profile_user@example.com'
    token = signup_and_token(client, email)
    headers = {'Authorization': f'Bearer {token}'}

    # get profile (created on demand)
    r = client.get('/api/profile', headers=headers)
    assert r.status_code == 200
    p = r.json()
    assert p['user_id']

    # update consent and notification prefs
    upd = {
        'consent_privacy': True,
        'notify_email': True,
        'notify_push': True,
        'notify_sms': False,
        'display_name': 'Tester'
    }
    u = client.patch('/api/profile', json=upd, headers=headers)
    assert u.status_code == 200
    out = u.json()
    assert out['display_name'] == 'Tester'
    assert out['consent_privacy'] is True

    # check audit entries exist
    a = client.get('/api/profile/audits', headers=headers)
    assert a.status_code == 200
    audits = a.json()
    # we expect at least entries for consent_privacy and notify_push/email
    fields = {it['field'] for it in audits}
    assert 'consent_privacy' in fields
    assert 'notify_email' in fields or 'notify_push' in fields
