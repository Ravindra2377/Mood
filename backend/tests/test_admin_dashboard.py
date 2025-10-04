from fastapi.testclient import TestClient
from app.main import app


def test_admin_dashboard_requires_auth():
    client = TestClient(app)
    r = client.get('/admin/analytics')
    # without auth it should return 401 or 403 depending on require_role implementation
    assert r.status_code in (401, 403)
