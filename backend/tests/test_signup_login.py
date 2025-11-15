import os
import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

# Ensure sqlite test DB & dev preview flags for deterministic duplicate signup behavior
os.environ.setdefault("DATABASE_URL", "sqlite:///./test_db.sqlite3")
os.environ.setdefault("DEV_MODE", "True")
os.environ.setdefault("DEV_EMAIL_PREVIEW", "True")

from app.main import app  # noqa: E402
from app.models.user import User  # noqa: E402
from app.services import security  # noqa: E402


@pytest.fixture
def client():
    return TestClient(app)


def _get_db() -> Session:
    from app.main import SessionLocal
    return SessionLocal()


def test_signup_persists_user_and_hashes_password(client):
    email = "signup_persist@example.com"
    pw = "Persist123!"
    r = client.post("/api/auth/signup", json={"email": email, "password": pw})
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["email"] == email
    assert "id" in body

    # Verify user row exists and password is stored hashed (not raw)
    db = _get_db()
    try:
        user = db.query(User).filter(User.email == email).first()
        assert user is not None
        assert user.hashed_password != pw
        assert security.verify_password(pw, user.hashed_password)
    finally:
        db.close()


def test_duplicate_signup_returns_existing_in_dev_preview(client):
    email = "duplicate_dev@example.com"
    pw = "Dup123!"
    first = client.post("/api/auth/signup", json={"email": email, "password": pw})
    assert first.status_code == 200
    second = client.post("/api/auth/signup", json={"email": email, "password": pw})
    # In DEV_EMAIL_PREVIEW mode, code path returns existing user instead of error
    assert second.status_code == 200
    assert second.json()["email"] == email
    assert first.json()["id"] == second.json()["id"], "Should reuse same user id"


def test_login_success_and_tokens(client):
    email = "login_success@example.com"
    pw = "LogInPass456!"
    r = client.post("/api/auth/signup", json={"email": email, "password": pw})
    assert r.status_code == 200
    t = client.post(
        "/api/auth/token",
        data={"username": email, "password": pw},
        headers={"Content-Type": "application/x-www-form-urlencoded"},
    )
    assert t.status_code == 200, t.text
    j = t.json()
    assert "access_token" in j
    assert "refresh_token" in j
    assert j["token_type"] == "bearer"


def test_login_wrong_password_unauthorized(client):
    email = "wrong_pw_user@example.com"
    pw = "CorrectPass123!"
    client.post("/api/auth/signup", json={"email": email, "password": pw})
    bad = client.post(
        "/api/auth/token",
        data={"username": email, "password": "BadPass!"},
        headers={"Content-Type": "application/x-www-form-urlencoded"},
    )
    assert bad.status_code == 401
    assert bad.json().get("detail") == "Invalid credentials"


def test_json_login_endpoint(client):
    email = "json_login_user@example.com"
    pw = "JsonPWD987!"
    client.post("/api/auth/signup", json={"email": email, "password": pw})
    # /api/auth/login expects JSON body
    resp = client.post("/api/auth/login", json={"email": email, "password": pw})
    assert resp.status_code == 200
    data = resp.json()
    assert "access_token" in data and "refresh_token" in data
    assert data["user"]["email"] == email


def test_json_login_invalid_credentials(client):
    email = "json_login_fail@example.com"
    pw = "JsonFail456!"
    client.post("/api/auth/signup", json={"email": email, "password": pw})
    resp = client.post("/api/auth/login", json={"email": email, "password": "zzz"})
    assert resp.status_code == 401
    assert resp.json().get("detail") == "Invalid credentials"
