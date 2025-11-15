import os
from fastapi.testclient import TestClient

os.environ.setdefault('DATABASE_URL', 'sqlite:///./test_db.sqlite3')
os.environ.setdefault('DEV_MODE', 'True')

from app.main import app


def _signup_and_token(email: str, password: str = 'JournaL!234') -> str:
    c = TestClient(app)
    r = c.post('/api/auth/signup', json={'email': email, 'password': password})
    assert r.status_code in (200, 201), r.text
    t = c.post(
        '/api/auth/token',
        data={'username': email, 'password': password},
        headers={'Content-Type': 'application/x-www-form-urlencoded'},
    )
    assert t.status_code == 200, t.text
    return t.json()['access_token']


def test_journal_crud_and_ownership():
    client = TestClient(app)
    token_a = _signup_and_token('crud_a@example.com')
    token_b = _signup_and_token('crud_b@example.com')

    headers_a = {'Authorization': f'Bearer {token_a}'}
    headers_b = {'Authorization': f'Bearer {token_b}'}

    # Create by A
    create = client.post('/api/journal', json={
        'title': 'First',
        'content': 'My private entry',
        'mood': 'positive',
        'progress': 50
    }, headers=headers_a)
    assert create.status_code == 200, create.text
    entry = create.json()
    eid = entry['id']

    # Read by owner succeeds
    get_ok = client.get(f'/api/journal/{eid}', headers=headers_a)
    assert get_ok.status_code == 200
    assert get_ok.json()['title'] == 'First'

    # Read by other user returns 404 (not found to avoid info leak)
    get_other = client.get(f'/api/journal/{eid}', headers=headers_b)
    assert get_other.status_code == 404

    # Update by other user fails (404)
    upd_other = client.put(f'/api/journal/{eid}', json={'title': 'Hacked'}, headers=headers_b)
    assert upd_other.status_code == 404

    # Update by owner
    upd = client.put(f'/api/journal/{eid}', json={'title': 'Edited', 'content': 'Updated text'}, headers=headers_a)
    assert upd.status_code == 200
    assert upd.json()['title'] == 'Edited'

    # Delete by other user fails
    del_other = client.delete(f'/api/journal/{eid}', headers=headers_b)
    assert del_other.status_code == 404

    # Delete by owner
    del_ok = client.delete(f'/api/journal/{eid}', headers=headers_a)
    assert del_ok.status_code == 200

    # After delete, owner cannot fetch (404)
    get_after = client.get(f'/api/journal/{eid}', headers=headers_a)
    assert get_after.status_code == 404
