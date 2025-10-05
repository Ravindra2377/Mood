import importlib
from types import SimpleNamespace


def make_dummy_session(items):
    class DummyQuery:
        def __init__(self, items):
            self._items = items

        def filter(self, *args, **kwargs):
            return self

        def limit(self, n):
            return self

        def all(self):
            return self._items

    class DummySession:
        def __init__(self, items):
            self._items = items
            self.added = []
            self.committed = False

        def query(self, model):
            return DummyQuery(self._items)

        def add(self, obj):
            self.added.append(obj)

        def commit(self):
            self.committed = True

        def close(self):
            return None

    return DummySession(items)


class FakeEntry:
    def __init__(self, id, content, encryption_key):
        self.id = id
        self.user_id = 1
        self.title = 't'
        self.content = content
        self.encryption_key = encryption_key


def test_rotate_journal_keys_no_entries(monkeypatch):
    # Ensure app package loads from backend
    import sys, os
    backend_dir = os.path.join(os.path.dirname(__file__), '..')
    if backend_dir not in sys.path:
        sys.path.insert(0, backend_dir)

    ec = importlib.import_module('app.services.envelope_crypto')

    # Patch SessionLocal to return an empty session
    monkeypatch.setattr('app.main.SessionLocal', lambda: make_dummy_session([]))

    changed = ec.rotate_journal_keys('fake-kms', batch=10)
    assert changed == 0


def test_rotate_journal_keys_reencrypt(monkeypatch):
    import sys, os
    backend_dir = os.path.join(os.path.dirname(__file__), '..')
    if backend_dir not in sys.path:
        sys.path.insert(0, backend_dir)

    ec = importlib.import_module('app.services.envelope_crypto')

    entry = FakeEntry(1, 'oldct', 'oldenc')
    session = make_dummy_session([entry])

    monkeypatch.setattr('app.main.SessionLocal', lambda: session)

    # Mock decrypt and encrypt to simulate rewrapping
    monkeypatch.setattr(ec, 'decrypt_from_kms', lambda ct, ek: 'plaintext')
    monkeypatch.setattr(ec, 'encrypt_for_kms', lambda pt, kms: ('newct', 'newenc'))

    changed = ec.rotate_journal_keys('fake-kms', batch=10)
    assert changed == 1
    assert entry.content == 'newct'
    assert entry.encryption_key == 'newenc'
    assert session.committed is True
