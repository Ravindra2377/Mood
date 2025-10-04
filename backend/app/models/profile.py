from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Boolean
from datetime import datetime, timezone
from app.models import Base

class Profile(Base):
    __tablename__ = 'profiles'
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), unique=True, nullable=False)
    display_name = Column(String, nullable=True)
    language = Column(String, default='en')
    timezone = Column(String, nullable=True)
    consent_privacy = Column(Boolean, default=False)
    # Notification preferences
    notify_email = Column(Boolean, default=True)
    notify_push = Column(Boolean, default=False)
    notify_sms = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    # next scheduled notification (adaptive scheduling)
    next_notification_at = Column(DateTime(timezone=True), nullable=True)
    # preferred delivery window in local time (hours 0-23)
    preferred_notify_start = Column(Integer, default=9)
    preferred_notify_end = Column(Integer, default=21)
    # last time a scheduled notification was sent (helps avoid duplicates)
    last_notification_sent_at = Column(DateTime(timezone=True), nullable=True)
    # simple engagement flag: 'active', 'at_risk', 'inactive' - updated on activity/achievement
    engagement_status = Column(String, default='inactive')
