from fastapi.testclient import TestClient
from app.main import app, SessionLocal
from app.services.analytics import record_event
from app.services import security
from app.models.user import User


def create_admin():
    db = SessionLocal()
    try:
        u = User(email='admin@example.com', hashed_password=security.hash_password('pw'), role='admin')
        db.add(u)
        db.commit()
        db.refresh(u)
        return u.id
    finally:
        db.close()


def test_analytics_summary_endpoint():
    client = TestClient(app)
    # create some events
    record_event('signup', user_id=1)
    record_event('mood.create', user_id=1)
    record_event('community.post', user_id=2)

    admin_id = create_admin()
    token = security.create_access_token({"sub": str(admin_id), "role": "admin"})
    headers = {"Authorization": f"Bearer {token}"}
    r = client.get('/api/analytics/summary?days=7', headers=headers)
    assert r.status_code == 200
    data = r.json()
    assert 'by_type' in data
    assert 'daily' in data
    assert isinstance(data['by_type'], dict)
    assert isinstance(data['daily'], list)
