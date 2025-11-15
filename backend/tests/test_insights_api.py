import os
import asyncio
from fastapi.testclient import TestClient
from datetime import datetime, timezone

os.environ.setdefault('DATABASE_URL', 'sqlite:///./test_db.sqlite3')
os.environ.setdefault('DEV_MODE', 'True')

from app.main import app, SessionLocal  # noqa: E402
from app.models.user import User  # noqa: E402
from app.models.journal_entry import JournalEntry  # noqa: E402
from app.services import security  # noqa: E402


client = TestClient(app)


def _create_user(email: str, password: str) -> int:
    db = SessionLocal()
    try:
        u = User(email=email, hashed_password=security.hash_password(password))
        db.add(u)
        db.commit()
        db.refresh(u)
        return u.id
    finally:
        db.close()


def _token_for_user(user_id: int) -> str:
    return security.create_access_token({"sub": str(user_id), "role": "user"})


def test_insights_overall_sentiment_and_keywords():
    email = 'insights_user@example.com'
    user_id = _create_user(email, 'InsiGhTs123!')
    token = _token_for_user(user_id)
    headers = {'Authorization': f'Bearer {token}'}

    db = SessionLocal()
    try:
        now = datetime.now(timezone.utc)
        rows = [
            JournalEntry(user_id=user_id, content='great amazing day', sentiment='POSITIVE', created_at=now),
            JournalEntry(user_id=user_id, content='bad sad moment', sentiment='NEGATIVE', created_at=now),
            JournalEntry(user_id=user_id, content='awesome progress', sentiment='POSITIVE', created_at=now),
        ]
        for r in rows:
            db.add(r)
        db.commit()
    finally:
        db.close()

    resp = client.get('/api/v1/insights/insights', headers=headers)
    assert resp.status_code == 200, resp.text
    data = resp.json()
    # overall_sentiment counts reflect inserted rows
    assert data['overall_sentiment'].get('POSITIVE') == 2
    assert data['overall_sentiment'].get('NEGATIVE') == 1
    # keywords should be a list (may be empty if analyzer not enriching existing rows)
    assert 'top_keywords' in data
    assert isinstance(data['top_keywords'], list)


def test_insights_empty_user_returns_zero_counts():
    email = 'empty_insights@example.com'
    user_id = _create_user(email, 'Empty123!')
    token = _token_for_user(user_id)
    headers = {'Authorization': f'Bearer {token}'}
    resp = client.get('/api/v1/insights/insights', headers=headers)
    assert resp.status_code == 200
    data = resp.json()
    # Expect empty or zeroed sentiment counts
    assert isinstance(data.get('overall_sentiment'), dict)
    # No sentiments recorded yet -> either empty dict or zero values
    for v in data.get('overall_sentiment', {}).values():
        assert v == 0
    assert data.get('top_keywords') == [] or isinstance(data.get('top_keywords'), list)
