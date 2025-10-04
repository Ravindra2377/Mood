import logging
from datetime import datetime
from pathlib import Path
from app.services.analytics_export import export_to_csv, upload_to_s3
from app.services.analytics import _analytics_file
from app.config import settings

log = logging.getLogger('analytics_scheduler')


def _job_export_and_upload():
    try:
        if not _analytics_file.exists():
            log.info('No analytics file to export; skipping job')
            return
        ts = datetime.utcnow().strftime('%Y%m%dT%H%M%SZ')
        local_csv = f'tmp/analytics_export_{ts}.csv'
        exported = export_to_csv(local_csv)
        if not exported:
            log.warning('Export returned no file; skipping upload')
            return
        # upload if configured
        s3_bucket = getattr(settings, 'ANALYTICS_S3_BUCKET', None)
        if s3_bucket:
            key = f'analytics/{Path(exported).name}'
            ok = upload_to_s3(s3_bucket, key, exported)
            if not ok:
                log.error('Failed to upload analytics export to S3')
        else:
            log.info('ANALYTICS_S3_BUCKET not set; not uploading')
    except Exception:
        log.exception('analytics export job failed')


def start_scheduler():
    try:
        from apscheduler.schedulers.background import BackgroundScheduler
    except Exception:
        log.exception('APScheduler not available; analytics scheduler will not start')
        return

    sched = BackgroundScheduler()
    interval_minutes = getattr(settings, 'ANALYTICS_EXPORT_INTERVAL_MINUTES', 60)
    sched.add_job(_job_export_and_upload, 'interval', minutes=interval_minutes)
    sched.start()
    log.info('Analytics scheduler started; interval=%s minutes', interval_minutes)
