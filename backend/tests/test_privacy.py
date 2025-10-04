from fastapi.testclient import TestClient
from app.main import app


def signup_and_token(client, email='privacy_user@example.com', pw='pw'):
    r = client.post('/api/auth/signup', json={'email': email, 'password': pw})
    t = client.post('/api/auth/token', data={'username': email, 'password': pw})
    assert t.status_code == 200
    return t.json()['access_token']


def test_export_and_delete_flow(tmp_path):
    client = TestClient(app)
    token = signup_and_token(client)
    headers = {'Authorization': f'Bearer {token}'}
    # create a journal
    r = client.post('/api/journals', json={'title': 's', 'content': 's'}, headers=headers)
    assert r.status_code == 200
    # export
    r2 = client.get('/api/privacy/export', headers=headers)
    assert r2.status_code == 200
    data = r2.json()
    assert 'user' in data
    # delete request
    r3 = client.post('/api/privacy/delete', headers=headers)
    assert r3.status_code == 202
