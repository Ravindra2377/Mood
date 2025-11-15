import os
import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from datetime import datetime, timezone

os.environ.setdefault('DATABASE_URL', 'sqlite:///./test_db.sqlite3')

from app.models import Base  # noqa: E402
from app.models.journal_entry import JournalEntry  # noqa: E402
from app.services.insights_service import get_user_insights  # noqa: E402


@pytest.fixture(scope='module')
def db_session():
    engine = create_engine('sqlite:///./test_db.sqlite3')
    Base.metadata.create_all(engine)
    TestingSessionLocal = sessionmaker(bind=engine)
    session = TestingSessionLocal()
    try:
        yield session
    finally:
        session.close()


def test_overall_sentiment_counts(db_session):
    user_id = 777
    # Clear prior rows for this user
    db_session.query(JournalEntry).filter(JournalEntry.user_id == user_id).delete()
    db_session.commit()

    # Insert 5 entries: 3 positive, 2 negative
    now = datetime.now(timezone.utc)
    rows = [
        JournalEntry(user_id=user_id, content='good day', sentiment='POSITIVE', created_at=now),
        JournalEntry(user_id=user_id, content='great', sentiment='POSITIVE', created_at=now),
        JournalEntry(user_id=user_id, content='awesome', sentiment='POSITIVE', created_at=now),
        JournalEntry(user_id=user_id, content='bad', sentiment='NEGATIVE', created_at=now),
        JournalEntry(user_id=user_id, content='sad', sentiment='NEGATIVE', created_at=now),
    ]
    for r in rows:
        db_session.add(r)
    db_session.commit()

    insights = db_session.run_sync(lambda s: None) if hasattr(db_session, 'run_sync') else None
    # get_user_insights is async; call via event loop
    import asyncio
    result = asyncio.get_event_loop().run_until_complete(get_user_insights(user_id, db_session))

    assert result.overall_sentiment.get('POSITIVE') == 3
    assert result.overall_sentiment.get('NEGATIVE') == 2
