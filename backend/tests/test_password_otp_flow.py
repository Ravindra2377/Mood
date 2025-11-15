import os
import pytest
from fastapi.testclient import TestClient

# Ensure test DB (sqlite) is used
os.environ.setdefault("DATABASE_URL", "sqlite:///./test_db.sqlite3")
os.environ.setdefault("DEV_MODE", "True")
os.environ.setdefault("DEV_EMAIL_PREVIEW", "True")

from app.main import app  # noqa: E402

@pytest.fixture
def client():
    return TestClient(app)


def test_password_otp_reset_success(client):
    email = "otp_reset_user@example.com"
    initial_password = "StartPass123!"

    # 1. Signup
    r = client.post("/api/auth/signup", json={"email": email, "password": initial_password})
    assert r.status_code == 200, r.text

    # 2. Request OTP reset (6-digit code preview should appear in dev)
    req = client.post("/api/auth/password-otp/request", json={"email": email})
    assert req.status_code == 200, req.text
    body = req.json()
    assert "status" in body
    assert "preview" in body and "code" in body["preview"], body
    code = body["preview"]["code"]
    assert len(code) == 6 and code.isdigit()

    # 3. Confirm reset with new password
    new_password = "NewPass456!"
    confirm = client.post(
        "/api/auth/password-otp/confirm",
        json={"email": email, "code": code, "new_password": new_password},
    )
    assert confirm.status_code == 200, confirm.text
    assert confirm.json().get("status") == "ok"

    # 4. Login with new password
    login = client.post(
        "/api/auth/token",
        data={"username": email, "password": new_password, "grant_type": "password"},
        headers={"Content-Type": "application/x-www-form-urlencoded"},
    )
    assert login.status_code == 200, login.text
    data = login.json()
    assert "access_token" in data and "refresh_token" in data


def test_password_otp_reset_invalid_code(client):
    email = "otp_reset_fail@example.com"
    pw = "StartZxc123!"

    # Signup user
    r = client.post("/api/auth/signup", json={"email": email, "password": pw})
    assert r.status_code == 200, r.text

    # Request code
    req = client.post("/api/auth/password-otp/request", json={"email": email})
    assert req.status_code == 200, req.text

    # Use wrong code
    bad = client.post(
        "/api/auth/password-otp/confirm",
        json={"email": email, "code": "999999", "new_password": "Nope123!"},
    )
    assert bad.status_code == 400
    body = bad.json()
    assert body.get("detail") == "Invalid or expired code"


def test_password_otp_reset_expired_code(client, monkeypatch):
    # Force expiry by monkeypatching datetime.now to appear after expiry.
    import datetime
    email = "otp_reset_expired@example.com"
    pw = "StartAbc123!"

    r = client.post("/api/auth/signup", json={"email": email, "password": pw})
    assert r.status_code == 200

    req = client.post("/api/auth/password-otp/request", json={"email": email})
    assert req.status_code == 200
    code = req.json()["preview"]["code"]

    # Monkeypatch datetime.now to simulate +20 minutes
    from app.controllers import auth as auth_controller

    original_datetime = datetime.datetime

    class FakeDateTime(datetime.datetime):
        @classmethod
        def now(cls, tz=None):
            return original_datetime.now(tz=tz) + datetime.timedelta(minutes=20)

    monkeypatch.setattr(auth_controller, "datetime", datetime)
    monkeypatch.setattr(datetime, "datetime", FakeDateTime)

    bad = client.post(
        "/api/auth/password-otp/confirm",
        json={"email": email, "code": code, "new_password": "Expired123!"},
    )
    # Restore datetime to avoid side-effects (pytest will roll back monkeypatch automatically)
    assert bad.status_code == 400, bad.text
    assert bad.json().get("detail") == "Invalid or expired code"
