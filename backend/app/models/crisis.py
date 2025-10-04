from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Boolean, Text
from datetime import datetime, timezone
from app.models import Base


class CrisisAlert(Base):
    __tablename__ = 'crisis_alerts'
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False, index=True)
    source = Column(String, nullable=False)  # 'chat' | 'mood' | 'other'
    severity = Column(String, nullable=False)  # 'low' | 'medium' | 'high'
    details = Column(Text, nullable=True)
    resolved = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))


class CrisisAudit(Base):
    __tablename__ = 'crisis_audits'
    id = Column(Integer, primary_key=True, index=True)
    alert_id = Column(Integer, ForeignKey('crisis_alerts.id'), nullable=False, index=True)
    actor_user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    action = Column(String, nullable=False)  # 'resolved', 'notified', etc.
    note = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
