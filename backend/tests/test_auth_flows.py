import os
import pytest
from fastapi.testclient import TestClient

# Use an in-memory SQLite for tests so they don't try to connect to Postgres
os.environ.setdefault('DATABASE_URL', 'sqlite:///./test_db.sqlite3')

from app.main import app


@pytest.fixture
def client():
    return TestClient(app)


def test_password_reset_and_login(client):
    email = 'reset_user@example.com'
    pw = 'startpass'

    # signup
    r = client.post('/api/auth/signup', json={'email': email, 'password': pw})
    assert r.status_code == 200

    # request reset
    rr = client.post('/api/auth/password-reset/request', json={'email': email})
    assert rr.status_code == 200
    body = rr.json()
    assert 'reset_link' in body
    # extract token from reset_link
    token = body['reset_link'].split('token=')[-1]

    # confirm reset with new password
    new_pw = 'newsecret'
    rc = client.post('/api/auth/password-reset/confirm', json={'token': token, 'new_password': new_pw})
    assert rc.status_code == 200

    # login with new password
    t = client.post('/api/auth/token', data={'username': email, 'password': new_pw})
    assert t.status_code == 200
    assert 'access_token' in t.json()
    assert 'refresh_token' in t.json()


def test_verify_flow(client):
    email = 'verify_user@example.com'
    pw = 'pwverify'

    # signup
    r = client.post('/api/auth/signup', json={'email': email, 'password': pw})
    assert r.status_code == 200

    # request verification
    rv = client.post('/api/auth/verify', params={'email': email})
    assert rv.status_code == 200
    body = rv.json()
    assert 'verification_token' in body
    token = body['verification_token']

    # confirm verification
    rc = client.post('/api/auth/verify/confirm', params={'token': token})
    assert rc.status_code == 200

    # login successful and token contains role
    t = client.post('/api/auth/token', data={'username': email, 'password': pw})
    assert t.status_code == 200
    body = t.json()
    tok = body['access_token']
    assert tok
    assert 'refresh_token' in body


def test_refresh_and_revoke(client):
    email = 'refresh_user@example.com'
    pw = 'pwrefresh'
    # signup
    r = client.post('/api/auth/signup', json={'email': email, 'password': pw})
    assert r.status_code == 200
    # login to get refresh token
    t = client.post('/api/auth/token', data={'username': email, 'password': pw})
    assert t.status_code == 200
    body = t.json()
    assert 'refresh_token' in body
    rt = body['refresh_token']

    # use refresh to get new access token
    nr = client.post('/api/auth/refresh', json={'old_refresh_token': rt})
    assert nr.status_code == 200
    nb = nr.json()
    assert 'access_token' in nb
    assert 'refresh_token' in nb
    new_rt = nb['refresh_token']

    # old refresh token must now be invalid
    nr2 = client.post('/api/auth/refresh', json={'old_refresh_token': rt})
    assert nr2.status_code == 401

    # logout (revoke) the new refresh token
    lo = client.post('/api/auth/logout', json={'refresh_token': new_rt})
    assert lo.status_code == 200

    # refresh with revoked token should fail
    nr3 = client.post('/api/auth/refresh', json={'old_refresh_token': new_rt})
    assert nr3.status_code == 401
