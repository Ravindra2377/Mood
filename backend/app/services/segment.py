import logging
from typing import Any, Dict
from app.services import task_queue
from app.config import settings

log = logging.getLogger('segment')


def enqueue_track(event_name: str, user_id: int | None = None, properties: Dict[str, Any] | None = None):
    """Enqueue a call to Segment (or a stub) using the app's background queue.

    This uses the same in-process task queue by default. In production you may swap
    to Celery or another worker system.
    """
    task_queue.enqueue(_send_track, event_name, user_id, properties or {})


def _send_track(event_name: str, user_id: int | None, properties: Dict[str, Any]):
    """Send an HTTP request to Segment HTTP API if configured; otherwise log a stub.
    """
    write_key = getattr(settings, 'SEGMENT_WRITE_KEY', None)
    if not write_key:
        log.info('Segment not configured; would send: %s %s %s', event_name, user_id, properties)
        return True

    try:
        import requests
        from requests.auth import HTTPBasicAuth
    except Exception:
        log.exception('requests library not available for Segment call')
        return False

    payload = {
        'event': event_name,
        'properties': properties,
    }
    if user_id is not None:
        payload['userId'] = str(user_id)

    try:
        resp = requests.post('https://api.segment.io/v1/track', json=payload, auth=HTTPBasicAuth(write_key, ''))
        if resp.status_code >= 200 and resp.status_code < 300:
            log.info('Segment track sent: %s', event_name)
            return True
        else:
            log.error('Segment track failed: %s %s', resp.status_code, resp.text)
            return False
    except Exception:
        log.exception('Failed to call Segment')
        return False
