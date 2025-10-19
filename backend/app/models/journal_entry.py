from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Text, Date, Enum as SQLEnum
from datetime import datetime, timezone, date
from enum import Enum
from app.models import Base

class JournalMood(str, Enum):
    """Mood levels for journal entries"""
    ANGRY = "angry"
    SAD = "sad"
    NEUTRAL = "neutral"
    HAPPY = "happy"
    EXCITED = "excited"

class JournalEntry(Base):
    __tablename__ = 'journal_entries'
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    title = Column(String, nullable=True)
    # content stores ciphertext when encryption is enabled
    content = Column(Text, nullable=False)
    # encryption_key stores the KMS-encrypted data key (base64) when envelope encryption used
    encryption_key = Column(Text, nullable=True)
    # mood field to track emotional state during journaling
    mood = Column(SQLEnum(JournalMood), default=JournalMood.NEUTRAL, nullable=False)
    # character count for analytics
    character_count = Column(Integer, nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    # optional logical date for diary entries (YYYY-MM-DD)
    entry_date = Column(Date, nullable=True, default=lambda: date.today())
    # optional daily progress metric (e.g., 0-100) stored as integer
    progress = Column(Integer, nullable=True)
