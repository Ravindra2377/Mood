import os
from fastapi.testclient import TestClient

os.environ.setdefault('DATABASE_URL', 'sqlite:///./test_db.sqlite3')

from app.main import app

client = TestClient(app)


def signup_and_token(email='i18n_user@example.com', password='pw'):
    r = client.post('/api/auth/signup', json={'email': email, 'password': password})
    assert r.status_code == 200
    t = client.post('/api/auth/token', data={'username': email, 'password': password})
    assert t.status_code == 200
    return t.json()['access_token']


def test_i18n_get_set_and_translate():
    token = signup_and_token('i18n1@example.com', 'pw')
    headers = {'Authorization': f'Bearer {token}'}

    r = client.get('/api/me/language', headers=headers)
    assert r.status_code == 200
    assert r.json().get('language') == 'en'

    # set language to Spanish
    s = client.post('/api/me/language', params={'language': 'es'}, headers=headers)
    assert s.status_code == 200
    assert s.json().get('language') == 'es'

    # translate welcome key
    tr = client.get('/api/translate', params={'key': 'welcome', 'locale': 'es'}, headers=headers)
    assert tr.status_code == 200
    assert tr.json().get('text') == 'Bienvenido'
