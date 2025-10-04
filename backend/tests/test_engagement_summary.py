import os
from fastapi.testclient import TestClient

os.environ.setdefault('DATABASE_URL', 'sqlite:///./test_db.sqlite3')

from app.main import app

client = TestClient(app)


def test_engagement_summary_flow():
    # signup and login
    email = 'engage_user@example.com'
    pw = 'testpw'
    r = client.post('/api/auth/signup', json={'email': email, 'password': pw})
    assert r.status_code == 200

    t = client.post('/api/auth/token', data={'username': email, 'password': pw})
    assert t.status_code == 200
    token = t.json()['access_token']
    headers = {'Authorization': f'Bearer {token}'}

    # initial summary
    s = client.get('/api/engagement/summary', headers=headers)
    assert s.status_code == 200
    data = s.json()
    assert data['points'] == 0
    assert data['current_streak'] == 0
    assert data['achievements'] == 0

    # record activity (creates streak)
    r1 = client.post('/api/streaks/record', headers=headers)
    assert r1.status_code == 200

    # add an achievement (gives points)
    r2 = client.post('/api/achievements', json={'key': 'bucket', 'points': 5}, headers=headers)
    assert r2.status_code == 200

    # new summary should reflect changes
    s2 = client.get('/api/engagement/summary', headers=headers)
    assert s2.status_code == 200
    d2 = s2.json()
    assert d2['points'] >= 5
    assert d2['current_streak'] >= 1
    assert d2['achievements'] >= 1
