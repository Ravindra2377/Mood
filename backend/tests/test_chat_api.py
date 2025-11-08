import os
import json
import asyncio
import pytest
from fastapi.testclient import TestClient

os.environ.setdefault('DATABASE_URL', 'sqlite:///./test_db.sqlite3')
os.environ.setdefault('DEV_MODE', 'True')

from app.main import app, SessionLocal  # noqa: E402
from app.models.user import User  # noqa: E402
from app.services import security  # noqa: E402


def _user_and_token(email: str) -> tuple[int, str]:
    db = SessionLocal()
    try:
        u = User(email=email, hashed_password=security.hash_password('T3stPwd!'))
        db.add(u)
        db.commit()
        db.refresh(u)
        token = security.create_access_token({"sub": str(u.id), "role": "user"})
        return u.id, token
    finally:
        db.close()


@pytest.fixture
def client():
    return TestClient(app)


class FakeAIService:
    def __init__(self, tokens, raise_error=False):
        self.tokens = tokens
        self.raise_error = raise_error

    async def chat(self, message, history, context):
        if self.raise_error:
            # Simulate failure after first token
            yield "Hel"
            raise RuntimeError("stream error")
        for t in self.tokens:
            # Simulate async token stream
            await asyncio.sleep(0)
            yield t


def test_chat_interactive_stream_success(client, monkeypatch):
    # Arrange
    _, token = _user_and_token('chat_success@example.com')
    headers = {"Authorization": f"Bearer {token}"}

    # Monkeypatch get_ai_service to return our fake streamer
    from app.controllers import chat as chat_controller

    def _fake_get_ai_service():
        return FakeAIService(["Hello", " ", "world!"])

    monkeypatch.setattr(chat_controller, 'get_ai_service', _fake_get_ai_service)

    # Act
    resp = client.post(
        "/api/chat/interactive",
        headers=headers,
        json={"message": "Hi", "include_context": False},
        stream=True,
    )

    # Assert we received SSE chunks and final done event
    text = resp.text
    assert resp.status_code == 200, text
    # Each event is prefixed with 'data: '
    events = [line[len("data: "):] for line in text.splitlines() if line.startswith("data: ")]
    assert len(events) >= 2
    # Last event should include done=True and session_id/message_id
    last = json.loads(events[-1])
    assert last.get('done') is True
    assert 'session_id' in last


def test_chat_interactive_stream_error(monkeypatch):
    client = TestClient(app)
    _, token = _user_and_token('chat_error@example.com')
    headers = {"Authorization": f"Bearer {token}"}

    from app.controllers import chat as chat_controller

    def _fake_get_ai_service_error():
        return FakeAIService(["partial"], raise_error=True)

    monkeypatch.setattr(chat_controller, 'get_ai_service', _fake_get_ai_service_error)

    resp = client.post(
        "/api/chat/interactive",
        headers=headers,
        json={"message": "Hi"},
        stream=True,
    )

    assert resp.status_code == 200
    text = resp.text
    events = [line[len("data: "):] for line in text.splitlines() if line.startswith("data: ")]
    # Final event should carry an error notice with done=True
    assert any('"error"' in e for e in events)
    parsed = [json.loads(e) for e in events if 'done' in e]
    assert parsed[-1].get('done') is True
