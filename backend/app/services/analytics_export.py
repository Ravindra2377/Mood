import csv
import json
from pathlib import Path
from datetime import datetime
from app.services.analytics import _analytics_file
import logging
from app.config import settings
from typing import Optional

log = logging.getLogger('analytics_export')


def export_to_csv(target_path: str):
    """Read JSONL analytics file and export aggregated CSV rows (event_type, user_id, created_at, props).
    This is a simple export; in production you'd batch and stream to a remote sink.
    """
    src = _analytics_file
    if not src.exists():
        log.warning('No analytics file to export: %s', src)
        return None
    target = Path(target_path)
    target.parent.mkdir(parents=True, exist_ok=True)
    with src.open('r', encoding='utf-8') as fh, target.open('w', newline='', encoding='utf-8') as out:
        writer = csv.writer(out)
        writer.writerow(['event_type', 'user_id', 'created_at', 'props'])
        for line in fh:
            try:
                obj = json.loads(line)
                writer.writerow([obj.get('event_type'), obj.get('user_id'), obj.get('created_at'), json.dumps(obj.get('props'))])
            except Exception:
                continue
    return str(target)


def push_to_remote_stub(target_url: str):
    """Placeholder for pushing analytics to an external service (e.g., Segment, HTTP endpoint).
    In production, you'd support batching, retries, backoff, and authentication.
    """
    log.info('Would push analytics to %s (stub)', target_url)
    return True


def upload_to_s3(bucket: str, key: str, local_path: str) -> bool:
    """Upload a file to S3 using boto3 if available and configured.

    Returns True on success, False otherwise.
    """
    try:
        import importlib
        boto3 = importlib.import_module('boto3')
    except Exception:
        log.exception('boto3 not available')
        return False

    try:
        s3 = boto3.client('s3', aws_access_key_id=getattr(settings, 'AWS_ACCESS_KEY_ID', None),
                          aws_secret_access_key=getattr(settings, 'AWS_SECRET_ACCESS_KEY', None),
                          region_name=getattr(settings, 'AWS_REGION', None))
        s3.upload_file(local_path, bucket, key)
        log.info('Uploaded %s to s3://%s/%s', local_path, bucket, key)
        return True
    except Exception:
        log.exception('Failed uploading to S3')
        return False

