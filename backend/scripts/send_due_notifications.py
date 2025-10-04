"""Simple sender script to find due notifications, send them, and reschedule.
Run from repository root: python scripts/send_due_notifications.py
"""
import sys
from pathlib import Path
# Ensure project root (backend/) is on sys.path so 'app' package imports work when running the script
script_dir = Path(__file__).resolve().parent
project_root = script_dir.parent
sys.path.insert(0, str(project_root))

import os, time, argparse

# CLI: parse --db and --seed early so we can set DATABASE_URL before importing the app
early_parser = argparse.ArgumentParser(add_help=False)
early_parser.add_argument('--db', help='Path to sqlite DB file or full DATABASE_URL')
early_parser.add_argument('--seed', action='store_true', help='Create a demo user/profile with notification due now')
known_args, remaining_argv = early_parser.parse_known_args()

# determine DATABASE_URL: prefer explicit --db, then existing env, otherwise create temp sqlite
if known_args.db:
    db_arg = known_args.db
    if db_arg.startswith('sqlite://') or '://' in db_arg:
        os.environ['DATABASE_URL'] = db_arg
    else:
        # treat as filepath
        os.environ['DATABASE_URL'] = f'sqlite:///{db_arg}'
else:
    os.environ.setdefault('DATABASE_URL', '')
    if not os.environ.get('DATABASE_URL'):
        tmp_db = f".tmp_scheduler_{int(time.time())}.sqlite3"
        os.environ['DATABASE_URL'] = f'sqlite:///{tmp_db}'

from app.main import SessionLocal
from app.models import Base
from app.main import engine

# ensure all tables exist in the demo DB
Base.metadata.create_all(bind=engine)
from app.services.scheduler import due_notifications, schedule_for_profile
from app.services.email import send_email
from app.services.i18n import t_format
from app.models.profile import Profile
from app.models.user import User
from datetime import datetime, timezone

# we will reparse argv inside run for help/remaining args
import shlex


def send_for_profile(db, profile: Profile):
    # placeholder message; in real app we'd pick from recommendations
    # Resolve locale from profile if present
    locale = getattr(profile, 'language', 'en') or 'en'
    subject = t_format('scheduled_checkin_subject', locale)
    body_html = t_format('scheduled_checkin_html', locale)
    body_text = t_format('scheduled_checkin_text', locale)
    sent = False
    if profile.notify_email:
        try:
            # resolve user email from DB to avoid depending on relationship mapping
            user = db.query(User).filter(User.id == profile.user_id).first()
            to_addr = user.email if user and user.email else 'user@example.com'
            res = send_email(to=to_addr, subject=subject, html_body=body_html, text_body=body_text)
            # print dev preview path if available
            if isinstance(res, dict) and res.get('preview_file'):
                print('Email preview written to:', res.get('preview_file'))
            sent = True
        except Exception as e:
            print('email send failed for user', profile.user_id, e)
    # push/sms placeholder
    if profile.notify_push:
        print('Would send push to user', profile.user_id)
    if profile.notify_sms:
        print('Would send sms to user', profile.user_id)

    if sent:
        profile.last_notification_sent_at = datetime.now(timezone.utc)
        db.add(profile)
        db.commit()


def run():
    # reparse args to include any other flags (we already consumed --db/--seed)
    parser = argparse.ArgumentParser()
    parser.add_argument('--db', help='Path to sqlite DB file or full DATABASE_URL')
    parser.add_argument('--seed', action='store_true', help='Create a demo user/profile with notification due now')
    args = parser.parse_args()
    db = SessionLocal()
    try:
        if args.seed or known_args.seed:
            # create demo user + profile with a due notification
            demo_email = 'demo_user@example.com'
            existing = db.query(User).filter(User.email == demo_email).first()
            if not existing:
                demo_user = User(email=demo_email, hashed_password='demo')
                db.add(demo_user)
                db.commit()
                db.refresh(demo_user)
            else:
                demo_user = existing
            p = db.query(Profile).filter(Profile.user_id == demo_user.id).first()
            now = datetime.now(timezone.utc)
            if not p:
                p = Profile(user_id=demo_user.id, notify_email=True, timezone='UTC', preferred_notify_start=0, preferred_notify_end=23, next_notification_at=now)
                db.add(p)
            else:
                p.notify_email = True
                p.timezone = 'UTC'
                p.preferred_notify_start = 0
                p.preferred_notify_end = 23
                p.next_notification_at = now
                db.add(p)
            db.commit()
            db.refresh(p)

        rows = due_notifications(db, lookahead_minutes=60)
        print('Found', len(rows), 'profiles with due notifications')
        for p in rows:
            # eager-load user relationship if available
            try:
                _ = p.user
            except Exception:
                pass
            print('Sending for user', p.user_id)
            send_for_profile(db, p)
            # reschedule
            schedule_for_profile(db, p)
    finally:
        db.close()


if __name__ == '__main__':
    run()
