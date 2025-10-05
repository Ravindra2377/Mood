from sqlalchemy import Column, Integer, DateTime, String, ForeignKey
from datetime import datetime, timezone
from app.models import Base


class Stopwatch(Base):
    __tablename__ = 'stopwatches'
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    label = Column(String, nullable=True)
    started_at = Column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    stopped_at = Column(DateTime(timezone=True), nullable=True)
