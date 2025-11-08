import os
import time
import pytest
from fastapi.testclient import TestClient

# Ensure isolated test DB & dev preview flags
os.environ.setdefault("DATABASE_URL", "sqlite:///./test_db.sqlite3")
os.environ.setdefault("DEV_MODE", "True")
os.environ.setdefault("DEV_EMAIL_PREVIEW", "True")

from app.main import app  # noqa: E402


@pytest.fixture
def client():
    return TestClient(app)


def _signup(client, email: str, password: str = "Rat3Lim!t123"):
    r = client.post("/api/auth/signup", json={"email": email, "password": password})
    assert r.status_code == 200, r.text


def test_password_otp_rate_limit_headers_present(client):
    """Exhaust /password-otp/request until 429 and assert rate-limit headers are attached.

    We do not assert exact numeric value but ensure Retry-After and X-RateLimit-Reset exist
    so the Flutter client can drive countdown UI.
    """
    email = "ratelimit_user@example.com"
    _signup(client, email)

    # Hit endpoint repeatedly until 429 (limit is 5/min per auth.py decorator)
    last_response = None
    for i in range(10):
        resp = client.post("/api/auth/password-otp/request", json={"email": email})
        last_response = resp
        if resp.status_code == 429:
            break
        else:
            assert resp.status_code == 200, f"Unexpected status {resp.status_code} before limit"

    assert last_response is not None
    assert last_response.status_code == 429, "Expected to reach rate limit but did not"

    # Headers set by custom handler in app.limits.rate_limit_handler
    retry_after = last_response.headers.get("Retry-After")
    reset_epoch = last_response.headers.get("X-RateLimit-Reset")

    assert retry_after is not None, "Retry-After header missing"
    assert reset_epoch is not None, "X-RateLimit-Reset header missing"

    # Basic sanity: headers parse as positive integers
    try:
        ra_int = int(retry_after)
        assert ra_int >= 0
    except Exception:
        pytest.fail(f"Retry-After not an int: {retry_after}")

    try:
        reset_int = int(reset_epoch)
        # reset time should be in the future (allow slight clock skew)
        assert reset_int >= int(time.time()) - 2
    except Exception:
        pytest.fail(f"X-RateLimit-Reset not an int: {reset_epoch}")


def test_password_otp_rate_limit_does_not_leak_code(client):
    """After hitting rate limit, body should be generic (no preview code leakage)."""
    email = "ratelimit_body_user@example.com"
    _signup(client, email)
    # Exhaust limit
    for _ in range(6):
        client.post("/api/auth/password-otp/request", json={"email": email})
    resp = client.post("/api/auth/password-otp/request", json={"email": email})
    assert resp.status_code == 429
    body = resp.text.lower()
    # The handler returns plain text "Too Many Requests"
    assert "too many" in body
    # Ensure no JSON preview pattern accidentally exposed
    assert "preview" not in body
