import os
from fastapi.testclient import TestClient

os.environ.setdefault('DATABASE_URL', 'sqlite:///./test_db.sqlite3')

from app.main import app

client = TestClient(app)


def signup_and_login(email='mood@example.com', password='testpass'):
    # create user
    r = client.post('/api/auth/signup', json={'email': email, 'password': password})
    assert r.status_code in (200, 201)
    # login
    r2 = client.post('/api/auth/token', data={'username': email, 'password': password})
    assert r2.status_code == 200
    tok = r2.json()['access_token']
    return tok


def test_mood_journal_symptom_and_analytics():
    token = signup_and_login()
    headers = {'Authorization': f'Bearer {token}'}

    # create moods
    for s in [3, 5, 7]:
        r = client.post('/api/moods', json={'score': s, 'note': f'note {s}'}, headers=headers)
        assert r.status_code == 200

    # create journals
    r = client.post('/api/journals', json={'title': 'entry1', 'content': 'I felt ok'}, headers=headers)
    assert r.status_code == 200

    # create symptoms
    r = client.post('/api/symptoms', json={'symptom': 'anxiety', 'severity': 6}, headers=headers)
    assert r.status_code == 200
    r = client.post('/api/symptoms', json={'symptom': 'fatigue', 'severity': 4}, headers=headers)
    assert r.status_code == 200

    # analytics
    r = client.get('/api/moods/analytics', headers=headers)
    assert r.status_code == 200
    data = r.json()
    assert 'average_mood' in data and data['entries_count'] == 3
    assert isinstance(data['most_common_symptoms'], list)
