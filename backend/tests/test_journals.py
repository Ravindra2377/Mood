import os
from fastapi.testclient import TestClient
from datetime import datetime, timedelta

os.environ.setdefault('DATABASE_URL', 'sqlite:///./test_db.sqlite3')
from app.main import app

client = TestClient(app)


def signup_and_login(email='journal@example.com', password='testpass'):
    r = client.post('/api/auth/signup', json={'email': email, 'password': password})
    assert r.status_code in (200, 201)
    r2 = client.post('/api/auth/token', data={'username': email, 'password': password})
    assert r2.status_code == 200
    return r2.json()['access_token']


def test_journal_create_and_query_by_date():
    token = signup_and_login('a@example.com')
    headers = {'Authorization': f'Bearer {token}'}

    today = datetime.utcnow().date().isoformat()
    payload = {'title': 'day1', 'content': 'progress note', 'entry_date': today, 'progress': 70}
    r = client.post('/api/journals', json=payload, headers=headers)
    assert r.status_code == 200
    data = r.json()
    assert data['title'] == 'day1'
    assert data['progress'] == 70

    # query by date
    r2 = client.get(f'/api/journals?date={today}', headers=headers)
    assert r2.status_code == 200
    items = r2.json()
    assert any(it['title'] == 'day1' for it in items)


def test_journal_date_parse_edge_case():
    token = signup_and_login('b@example.com')
    headers = {'Authorization': f'Bearer {token}'}

    # create one entry without entry_date
    r = client.post('/api/journals', json={'title': 'no-date', 'content': 'x'}, headers=headers)
    assert r.status_code == 200

    # call with invalid date -> our endpoint ignores parse error and returns unfiltered list
    r2 = client.get('/api/journals?date=not-a-date', headers=headers)
    assert r2.status_code == 200
    items = r2.json()
    assert isinstance(items, list)


def test_journals_progress_summary():
    token = signup_and_login('c@example.com')
    headers = {'Authorization': f'Bearer {token}'}

    d1 = datetime.utcnow().date()
    d2 = d1 - timedelta(days=1)
    # create entries for two dates
    client.post('/api/journals', json={'title': 'a', 'content': 'x', 'entry_date': d1.isoformat(), 'progress': 80}, headers=headers)
    client.post('/api/journals', json={'title': 'b', 'content': 'x', 'entry_date': d2.isoformat(), 'progress': 60}, headers=headers)

    r = client.get('/api/journals/summary', headers=headers)
    assert r.status_code == 200
    data = r.json()
    assert 'daily' in data
    assert any(entry['avg_progress'] is not None for entry in data['daily'])
