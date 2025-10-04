from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from datetime import datetime, timezone
from app.models import Base

class SymptomEntry(Base):
    __tablename__ = 'symptom_entries'
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    symptom = Column(String, nullable=False)
    severity = Column(Integer, nullable=True)  # 0-10 scale
    note = Column(String, nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
