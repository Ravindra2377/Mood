import logging
from datetime import datetime, timezone, timedelta
from app.config import settings

log = logging.getLogger('retention')


def purge_old_data():
    days = getattr(settings, 'DATA_RETENTION_DAYS', None)
    if not days:
        log.info('DATA_RETENTION_DAYS not set; retention job disabled')
        return 0
    cutoff = datetime.now(timezone.utc) - timedelta(days=days)
    from app.main import SessionLocal
    from app.models.journal_entry import JournalEntry
    from app.models.mood_entry import MoodEntry
    db = SessionLocal()
    try:
        jcount = db.query(JournalEntry).filter(JournalEntry.created_at < cutoff).delete()
        mcount = db.query(MoodEntry).filter(MoodEntry.created_at < cutoff).delete()
        db.commit()
        total = (jcount or 0) + (mcount or 0)
        log.info('Retention purge removed %s records', total)
        return total
    except Exception:
        log.exception('Retention purge failed')
        return 0
    finally:
        db.close()


def start_retention_scheduler():
    try:
        import importlib
        mod = importlib.import_module('apscheduler.schedulers.background')
        BackgroundScheduler = getattr(mod, 'BackgroundScheduler')
    except Exception:
        log.exception('APScheduler not available; retention scheduler will not start')
        return

    sched = BackgroundScheduler()
    interval_minutes = getattr(settings, 'RETENTION_CHECK_INTERVAL_MINUTES', 24 * 60)
    sched.add_job(purge_old_data, 'interval', minutes=interval_minutes)
    sched.start()
    log.info('Retention scheduler started; interval=%s minutes', interval_minutes)
