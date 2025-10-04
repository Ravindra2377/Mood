from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class ProfileRead(BaseModel):
    id: int
    user_id: int
    display_name: Optional[str]
    language: str
    timezone: Optional[str]
    consent_privacy: bool
    notify_email: bool
    notify_push: bool
    notify_sms: bool
    created_at: datetime
    next_notification_at: Optional[datetime]
    preferred_notify_start: Optional[int]
    preferred_notify_end: Optional[int]
    last_notification_sent_at: Optional[datetime]
    engagement_status: Optional[str]

    model_config = {"from_attributes": True}

class ProfileUpdate(BaseModel):
    display_name: Optional[str] = None
    language: Optional[str] = None
    timezone: Optional[str] = None
    consent_privacy: Optional[bool] = None
    notify_email: Optional[bool] = None
    notify_push: Optional[bool] = None
    notify_sms: Optional[bool] = None
    next_notification_at: Optional[datetime] = None
    preferred_notify_start: Optional[int] = None
    preferred_notify_end: Optional[int] = None
    last_notification_sent_at: Optional[datetime] = None
    engagement_status: Optional[str] = None
