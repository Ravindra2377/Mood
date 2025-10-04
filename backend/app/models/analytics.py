from sqlalchemy import Column, Integer, String, DateTime, JSON
from datetime import datetime, timezone
from app.models import Base

class AnalyticsEvent(Base):
    __tablename__ = 'analytics_events'
    id = Column(Integer, primary_key=True, index=True)
    event_type = Column(String, index=True, nullable=False)
    user_id = Column(Integer, nullable=True, index=True)
    props = Column(JSON, nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
