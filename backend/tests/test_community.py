import os
from fastapi.testclient import TestClient

os.environ.setdefault('DATABASE_URL', 'sqlite:///./test_db.sqlite3')

from app.main import app

client = TestClient(app)


def signup_and_token(email='u@example.com', password='pw'):
    r = client.post('/api/auth/signup', json={'email': email, 'password': password})
    assert r.status_code == 200
    t = client.post('/api/auth/token', data={'username': email, 'password': password})
    assert t.status_code == 200
    return t.json()['access_token']


def test_community_flow():
    admin_token = signup_and_token('admin@example.com', 'pw')
    # make admin by hacking user record (simpler than adding admin creation flow)
    # fetch DB and set role
    from app.main import SessionLocal
    from app.models.user import User
    db = SessionLocal()
    u = db.query(User).filter(User.email == 'admin@example.com').first()
    u.role = 'admin'
    db.add(u)
    db.commit()
    admin_user_id = u.id
    db.close()

    headers = {'Authorization': f'Bearer {admin_token}'}

    # create group
    cg = client.post('/api/groups', json={'key': 'peer', 'title': 'Peer Support', 'description': 'group'}, headers=headers)
    assert cg.status_code == 200
    # create user and join
    token = signup_and_token('member@example.com', 'pw')
    mh = {'Authorization': f'Bearer {token}'}
    j = client.post('/api/groups/peer/join', headers=mh)
    assert j.status_code == 200

    # list members
    lm = client.get('/api/groups/peer/members', headers=headers)
    assert lm.status_code == 200
    # ensure member exists in the list and includes richer info for admin requester
    ms = lm.json()
    # fetch member id for member@example.com
    from app.main import SessionLocal
    from app.models.user import User
    db = SessionLocal()
    member_user = db.query(User).filter(User.email == 'member@example.com').first()
    assert member_user is not None
    member_user_id = member_user.id
    db.close()
    assert any(m['user_id'] == member_user_id for m in ms)
    # ensure display_name key is present (display_name may be None)
    assert 'display_name' in ms[0]

    # under 'hidden' policy (default), non-admins should not receive emails
    lm_nonadmin = client.get('/api/groups/peer/members', headers=mh)
    assert lm_nonadmin.status_code == 200
    for m in lm_nonadmin.json():
        assert m.get('email') is None

    # create post
    p = client.post('/api/posts', json={'group_key': 'peer', 'title': 'hello', 'body': 'hi'}, headers=mh)
    assert p.status_code == 200
    pid = p.json()['id']

    # comment
    c = client.post('/api/comments', json={'post_id': pid, 'body': 'reply'}, headers=mh)
    assert c.status_code == 200

    # flag post
    f = client.post(f'/api/posts/{pid}/flag', headers=mh)
    assert f.status_code == 200

    # moderator remove (admin should be able to remove)
    rem = client.post(f'/api/moderation/posts/{pid}/remove', headers=headers)
    assert rem.status_code == 200

    # create another post to test promote/demote
    p2 = client.post('/api/posts', json={'group_key': 'peer', 'title': 'second', 'body': 'body2'}, headers=mh)
    assert p2.status_code == 200
    pid2 = p2.json()['id']

    # promote member to moderator
    # admin promotes member
    promote = client.post(f'/api/groups/peer/members/{member_user_id}/promote', headers=headers)
    assert promote.status_code == 200

    # promoted member can now remove posts
    promote_headers = mh
    rem2 = client.post(f'/api/moderation/posts/{pid2}/remove', headers=promote_headers)
    assert rem2.status_code == 200
