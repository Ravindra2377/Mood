import os
import pytest
from datetime import datetime, timezone, timedelta

# Ensure test settings
os.environ.setdefault('DATABASE_URL', 'sqlite:///./test_db.sqlite3')
os.environ.setdefault('ACCESS_TOKEN_EXPIRE_MINUTES', '5')

from app.services import security  # noqa: E402


def test_create_access_token_contains_claims():
    token = security.create_access_token({'sub': '123', 'role': 'user'})
    payload = security.decode_access_token(token)
    assert payload.get('sub') == '123'
    assert payload.get('role') == 'user'
    assert 'exp' in payload
    # exp should be within configured window (allowing a few seconds drift)
    exp_dt = datetime.fromtimestamp(payload['exp'], tz=timezone.utc) if isinstance(payload['exp'], (int, float)) else payload['exp']
    now = datetime.now(timezone.utc)
    assert now < exp_dt <= now + timedelta(minutes=6)


def test_password_hash_and_verify():
    pw = 'S3cretPwd!'
    hashed = security.hash_password(pw)
    assert hashed != pw
    assert security.verify_password(pw, hashed)
    assert not security.verify_password('wrong', hashed)


def test_decode_invalid_token_returns_empty():
    bad = 'invalid.token.value'
    payload = security.decode_access_token(bad)
    assert payload == {}
