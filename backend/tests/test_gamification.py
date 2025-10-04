import os
import pytest
from fastapi.testclient import TestClient

# Use an in-memory SQLite for tests so they don't try to connect to Postgres
os.environ.setdefault('DATABASE_URL', 'sqlite:///./test_db.sqlite3')

from app.main import app


@pytest.fixture
def client():
    return TestClient(app)


def test_achievement_create_and_increment(client):
    # signup user
    resp = client.post('/api/auth/signup', json={'email': 'ci_user@example.com', 'password': 'pw123'})
    assert resp.status_code == 200

    # get token
    token_resp = client.post('/api/auth/token', data={'username': 'ci_user@example.com', 'password': 'pw123'})
    assert token_resp.status_code == 200
    token = token_resp.json()['access_token']
    headers = {'Authorization': f'Bearer {token}'}

    # list achievements (empty)
    r = client.get('/api/achievements', headers=headers)
    assert r.status_code == 200
    assert r.json() == []

    # create achievement
    c = client.post('/api/achievements', json={'key': 'ci_first', 'points': 7}, headers=headers)
    assert c.status_code == 200
    assert c.json()['points'] == 7

    # increment
    c2 = client.post('/api/achievements', json={'key': 'ci_first', 'points': 3}, headers=headers)
    assert c2.status_code == 200
    assert c2.json()['points'] == 10


def test_streak_and_rewards_flow(client):
    # signup user
    resp = client.post('/api/auth/signup', json={'email': 'ci_user2@example.com', 'password': 'pw123'})
    assert resp.status_code == 200

    token_resp = client.post('/api/auth/token', data={'username': 'ci_user2@example.com', 'password': 'pw123'})
    assert token_resp.status_code == 200
    token = token_resp.json()['access_token']
    headers = {'Authorization': f'Bearer {token}'}

    # record activity -> create streak
    r = client.post('/api/streaks/record', headers=headers)
    assert r.status_code == 200
    assert r.json()['current_streak'] >= 1

    # create a reward
    cr = client.post('/api/rewards', json={'key': 'free_coffee', 'title': 'Free Coffee', 'cost_points': 5}, headers=headers)
    assert cr.status_code == 200
    reward = cr.json()

    # user has no points yet, try claim -> should fail
    claim = client.post(f"/api/rewards/{reward['key']}/claim", headers=headers)
    assert claim.status_code == 400

    # give user points via achievement
    c = client.post('/api/achievements', json={'key': 'points_bucket', 'points': 10}, headers=headers)
    assert c.status_code == 200

    # now claim should succeed
    claim2 = client.post(f"/api/rewards/{reward['key']}/claim", headers=headers)
    assert claim2.status_code == 200
    assert claim2.json()['user_id'] is not None
