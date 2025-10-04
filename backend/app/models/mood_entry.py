from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from datetime import datetime, timezone
from app.models import Base

class MoodEntry(Base):
	__tablename__ = 'mood_entries'
	id = Column(Integer, primary_key=True, index=True)
	user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
	score = Column(Integer, nullable=False)
	note = Column(String, nullable=True)
	created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
