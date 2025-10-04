from datetime import datetime, timezone, timedelta, time
from sqlalchemy.orm import Session
from app.models.profile import Profile
from app.models.personalization import EngagementEvent
import zoneinfo


def compute_next_notification(db: Session, profile: Profile) -> datetime | None:
    """Compute the next notification time for a profile.
    Simple heuristic:
      - If user disabled all notifications, return None
      - If user has not engaged in >48 hours, schedule immediate (now + 5 minutes)
      - Otherwise schedule in 24 hours at a reasonable hour (now + 24h)
    """
    if not (profile.notify_email or profile.notify_push or profile.notify_sms):
        return None
    # find last engagement
    last = db.query(EngagementEvent).filter(EngagementEvent.user_id == profile.user_id).order_by(EngagementEvent.created_at.desc()).first()
    now_utc = datetime.now(timezone.utc)
    # determine user's timezone
    try:
        tz = zoneinfo.ZoneInfo(profile.timezone) if profile.timezone else timezone.utc
    except Exception:
        tz = timezone.utc
    now_local = now_utc.astimezone(tz)
    if not last:
        candidate_local = now_local + timedelta(minutes=5)
    else:
        age = now_utc - last.created_at
        if age > timedelta(hours=48):
            candidate_local = now_local + timedelta(minutes=5)
        else:
            candidate_local = now_local + timedelta(hours=24)

    # respect preferred window (local hours)
    start_h = profile.preferred_notify_start if profile.preferred_notify_start is not None else 9
    end_h = profile.preferred_notify_end if profile.preferred_notify_end is not None else 21
    # clamp candidate into the window; if outside, schedule at next day's start_h
    if start_h <= candidate_local.hour < end_h:
        chosen_local = candidate_local
    else:
        # schedule for next occurrence at start_h local
        next_day = (candidate_local + timedelta(days=1)).date()
        chosen_local = datetime.combine(next_day, time(hour=start_h), tzinfo=tz)

    # convert chosen_local back to UTC
    chosen_utc = chosen_local.astimezone(timezone.utc)
    return chosen_utc


def schedule_for_profile(db: Session, profile: Profile) -> Profile:
    next_at = compute_next_notification(db, profile)
    profile.next_notification_at = next_at
    db.add(profile)
    db.commit()
    db.refresh(profile)
    return profile


def due_notifications(db: Session, lookahead_minutes: int = 60):
    now = datetime.now(timezone.utc)
    horizon = now + timedelta(minutes=lookahead_minutes)
    return db.query(Profile).filter(Profile.next_notification_at != None, Profile.next_notification_at <= horizon).all()
