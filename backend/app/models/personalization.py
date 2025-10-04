from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, JSON
from datetime import datetime, timezone
from sqlalchemy.orm import relationship
from app.models import Base


class EngagementEvent(Base):
    __tablename__ = 'engagement_events'
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False, index=True)
    event_type = Column(String, nullable=False)
    # use attribute name `meta` to avoid clashing with Declarative `metadata`
    meta = Column('metadata', JSON, nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))

    user = relationship('User', backref='engagement_events')


class Recommendation(Base):
    __tablename__ = 'recommendations'
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False, index=True)
    content_key = Column(String, nullable=False)
    score = Column(Integer, nullable=False, default=0)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))

    user = relationship('User', backref='recommendations')
