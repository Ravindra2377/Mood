from sqlalchemy import Column, Integer, DateTime, String, ForeignKey
from datetime import datetime, timezone
from app.models import Base


class SleepEntry(Base):
    __tablename__ = 'sleep_entries'
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    sleep_start = Column(DateTime(timezone=True), nullable=False)
    sleep_end = Column(DateTime(timezone=True), nullable=True)
    quality = Column(String, nullable=True)  # e.g., 'good', 'poor', or numeric string
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
