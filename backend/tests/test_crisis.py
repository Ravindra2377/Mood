import os
from fastapi.testclient import TestClient

os.environ.setdefault('DATABASE_URL', 'sqlite:///./test_db.sqlite3')

from app.main import app

client = TestClient(app)


def signup_and_token(email='c@example.com', password='pw'):
    r = client.post('/api/auth/signup', json={'email': email, 'password': password})
    assert r.status_code == 200
    t = client.post('/api/auth/token', data={'username': email, 'password': password})
    assert t.status_code == 200
    return t.json()['access_token']


def test_crisis_detection_and_resources():
    token = signup_and_token('crisis_user@example.com', 'pw')
    headers = {'Authorization': f'Bearer {token}'}

    # analyze a high-risk phrase
    r = client.post('/api/crisis/analyze_text', params={'text': 'I want to die and kill myself'}, headers=headers)
    assert r.status_code == 200
    assert r.json().get('alerted') is True
    assert r.json().get('severity') == 'high'

    # list resources
    res = client.get('/api/crisis/resources')
    assert res.status_code == 200
    assert isinstance(res.json(), list)
    assert any(r.get('country') == 'US' for r in res.json())

    # escalation: since DEV_EMAIL_PREVIEW is True by default, check preview file creation
    # ensure at least one preview file is created under tmp/email-previews
    import time
    time.sleep(0.1)
    import glob
    previews = glob.glob('tmp/email-previews/*.html')
    assert len(previews) > 0

    # moderation: create an admin user and list unresolved alerts
    admin_token = signup_and_token('admin2@example.com', 'pw')
    # promote to admin via DB
    from app.main import SessionLocal
    from app.models.user import User
    db = SessionLocal()
    admin_user = db.query(User).filter(User.email == 'admin2@example.com').first()
    admin_user.role = 'admin'
    db.add(admin_user)
    db.commit()
    admin_id = admin_user.id
    db.close()

    admin_headers = {'Authorization': f'Bearer {admin_token}'}
    lm = client.get('/api/crisis/alerts', headers=admin_headers)
    assert lm.status_code == 200
    alerts = lm.json()
    assert isinstance(alerts, list)
    assert len(alerts) > 0

    # resolve the first alert
    aid = alerts[0]['id']
    res = client.post(f'/api/crisis/alerts/{aid}/resolve', headers=admin_headers)
    assert res.status_code == 200
    assert res.json().get('resolved') is True
