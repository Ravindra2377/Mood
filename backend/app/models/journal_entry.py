from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Text, Date, Enum as SQLEnum, Float
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
    # ai-generated sentiment label (e.g., positive/neutral/negative)
    sentiment = Column(String(32), nullable=True)
    # confidence score from sentiment model (0-1)
    sentiment_score = Column(Float, nullable=True)
    # comma-separated keywords extracted from entry text
    keywords = Column(Text, nullable=True)
