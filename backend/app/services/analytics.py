import json
from datetime import datetime, timezone
from pathlib import Path
import logging

log = logging.getLogger('analytics')

# file-based fallback for quick inspection
_analytics_file = Path(__file__).parent.parent / 'tmp' / 'analytics.jsonl'
_analytics_file.parent.mkdir(parents=True, exist_ok=True)


def _write_file(event: dict):
    try:
        with _analytics_file.open('a', encoding='utf-8') as fh:
            fh.write(json.dumps(event, default=str) + '\n')
    except Exception as e:
        log.exception('Failed writing analytics file: %s', e)


def record_event(event_type: str, user_id: int | None = None, props: dict | None = None):
    """Record an analytics event to DB and append to a local file (for quick dashboards).
    This function is intentionally resilient: failures will not raise to callers.
    """
    now = datetime.now(timezone.utc)
    # validate and scrub props
    try:
        from app.services.analytics_schema import validate_and_scrub
        ok, cleaned, err = validate_and_scrub(event_type, props or {})
        if not ok:
            log.error('Analytics event validation failed: %s', err)
            # do not record invalid events
            return None
        props = cleaned
    except Exception:
        # if schema validation fails unexpectedly, continue with original props but log
        log.exception('Analytics schema validation error; proceeding with raw props')

    ev = {'event_type': event_type, 'user_id': user_id, 'props': props or {}, 'created_at': now.isoformat()}
    # append to file (best-effort)
    try:
        _write_file(ev)
    except Exception:
        pass
    # store to DB (lazy imports to avoid circular import at module import time)
    try:
        from app.main import SessionLocal
        from app.models.analytics import AnalyticsEvent
        db = SessionLocal()
        try:
            a = AnalyticsEvent(event_type=event_type, user_id=user_id, props=props or {})
            db.add(a)
            db.commit()
        finally:
            db.close()
    except Exception as e:
        log.exception('Failed to save analytics event to DB: %s', e)

    # also enqueue to Segment in background (best-effort)
    try:
        from app.services.segment import enqueue_track
        enqueue_track(event_type, user_id=user_id, properties=props or {})
    except Exception:
        log.exception('Failed to enqueue segment event')

    return ev
