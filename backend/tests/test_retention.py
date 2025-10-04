from app.services.retention import purge_old_data
from app.main import SessionLocal
from app.models.journal_entry import JournalEntry
from app.models.mood_entry import MoodEntry
from datetime import datetime, timezone, timedelta
from app.config import settings


def test_purge_old_data(tmp_path, monkeypatch):
    # set retention to 0 days so any created records are purged
    monkeypatch.setattr(settings, 'DATA_RETENTION_DAYS', 1, raising=False)
    db = SessionLocal()
    try:
        now = datetime.now(timezone.utc) - timedelta(days=10)
        j = JournalEntry(user_id=1, title='old', content='x', created_at=now)
        m = MoodEntry(user_id=1, score=1, created_at=now)
        db.add(j); db.add(m); db.commit()
    finally:
        db.close()

    removed = purge_old_data()
    assert removed >= 2
