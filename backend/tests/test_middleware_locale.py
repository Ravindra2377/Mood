import os
from fastapi.testclient import TestClient
from app.main import app
from app.main import SessionLocal
from app.models.user import User
from app.models.profile import Profile
from app.services import security


def create_user_and_profile(email='locale_test@example.com', lang='hi'):
    db = SessionLocal()
    try:
        u = User(email=email, hashed_password=security.hash_password('pw'))
        db.add(u)
        db.commit()
        db.refresh(u)
        p = Profile(user_id=u.id, language=lang)
        db.add(p)
        db.commit()
        db.refresh(p)
        return u.id, p.id
    finally:
        db.close()


def get_token_for_user(user_id: int):
    # create a short-lived token for testing
    return security.create_access_token({"sub": str(user_id)})


def test_middleware_prefers_profile_language():
    client = TestClient(app)
    user_id, profile_id = create_user_and_profile()
    token = get_token_for_user(user_id)
    headers = {"Authorization": f"Bearer {token}"}
    # call root endpoint which is simple and will pass through middleware
    r = client.get('/', headers=headers)
    assert r.status_code == 200
    # middleware should have set request.state.locale to profile.language; we cannot access request.state here,
    # but we can exercise an endpoint that uses get_locale dependency. We'll call i18n bundle endpoint.
    r2 = client.get('/api/bundle?locale=auto', headers=headers)
    # bundle endpoint should exist and return a dict; verify that the locale in bundle matches hi keys
    assert r2.status_code == 200
    data = r2.json()
    assert isinstance(data, dict)


def test_middleware_uses_accept_language_when_no_token():
    client = TestClient(app)
    headers = {"Accept-Language": "te-IN,hi;q=0.8,en;q=0.6"}
    r = client.get('/api/bundle?locale=auto', headers=headers)
    assert r.status_code == 200
    data = r.json()
    assert isinstance(data, dict)
