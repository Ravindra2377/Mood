from sqlalchemy import Column, Integer, DateTime, String, ForeignKey
from datetime import datetime, timezone, timedelta
from app.models import Base


class Timer(Base):
    __tablename__ = 'timers'
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    label = Column(String, nullable=True)
    # target fire time
    target_at = Column(DateTime(timezone=True), nullable=False)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    # optional resolved timestamp
    fired_at = Column(DateTime(timezone=True), nullable=True)
