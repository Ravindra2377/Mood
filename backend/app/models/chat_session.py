"""
Chat session and message models for AI-powered mental health conversations.
Includes crisis detection logging and moderation capabilities.
"""

from sqlalchemy import Column, Integer, String, Text, DateTime, Boolean, ForeignKey, JSON, ARRAY
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from uuid import uuid4
from datetime import datetime

from app.models import Base


class ChatSession(Base):
    """Represents a chat session between user and AI."""
    
    __tablename__ = "chat_sessions"
    
    id = Column(String, primary_key=True, default=lambda: str(uuid4()))
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    started_at = Column(DateTime, nullable=False, default=datetime.utcnow)
    ended_at = Column(DateTime, nullable=True)
    is_active = Column(Boolean, default=True, index=True)
    
    # Session context
    session_mood = Column(String(50), nullable=True)  # anxiety, depression, stress, etc.
    session_intensity = Column(Integer, nullable=True)  # 1-10 scale
    session_triggers = Column(ARRAY(String), default=list)  # Array of trigger keywords
    
    # Statistics
    total_messages = Column(Integer, default=0)
    is_crisis_escalated = Column(Boolean, default=False)
    
    # Timestamps
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)
    updated_at = Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    messages = relationship("ChatMessage", back_populates="session", cascade="all, delete-orphan")
    
    def __repr__(self):
        return f"<ChatSession(id={self.id}, user_id={self.user_id}, is_active={self.is_active})>"


class ChatMessage(Base):
    """Represents a single message in a chat session."""
    
    __tablename__ = "chat_messages"
    
    id = Column(String, primary_key=True, default=lambda: str(uuid4()))
    session_id = Column(String, ForeignKey("chat_sessions.id", ondelete="CASCADE"), nullable=False, index=True)
    
    # Message metadata
    role = Column(String(20), nullable=False)  # 'user', 'assistant', or 'system'
    content = Column(Text, nullable=False)
    
    # Processing info
    tokens_used = Column(Integer, nullable=True)
    model_used = Column(String(50), nullable=True)  # 'gpt-4', 'gpt-3.5-turbo', etc.
    streaming_completed = Column(Boolean, default=False)
    response_time_ms = Column(Integer, nullable=True)
    
    # Safety flags
    flagged_by_moderation = Column(Boolean, default=False)
    contains_crisis_keywords = Column(Boolean, default=False)
    
    # Timestamps
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow, index=True)
    
    # Relationships
    session = relationship("ChatSession", back_populates="messages")
    
    def __repr__(self):
        return f"<ChatMessage(id={self.id}, role={self.role}, session_id={self.session_id})>"


class ModerationLog(Base):
    """Logs content that was flagged by moderation for human review."""
    
    __tablename__ = "moderation_logs"
    
    id = Column(String, primary_key=True, default=lambda: str(uuid4()))
    message_id = Column(String, ForeignKey("chat_messages.id"), nullable=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    
    # Content and reason
    flagged_content = Column(Text, nullable=False)
    moderation_reason = Column(String(255), nullable=False)
    severity_level = Column(String(20), nullable=False)  # low, medium, high, critical
    
    # Review status
    human_reviewed = Column(Boolean, default=False)
    reviewer_notes = Column(Text, nullable=True)
    
    # Timestamps
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow, index=True)
    
    def __repr__(self):
        return f"<ModerationLog(id={self.id}, severity={self.severity_level}, reviewed={self.human_reviewed})>"


class UserContextCache(Base):
    """Caches user context (mood, activities, pathways) for AI personalization."""
    
    __tablename__ = "user_context_cache"
    
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), primary_key=True)
    
    # Cached data as JSON
    latest_mood_entry = Column(JSON, nullable=True)
    recent_activities = Column(JSON, nullable=True)
    active_pathways = Column(JSON, nullable=True)
    assessment_scores = Column(JSON, nullable=True)
    
    # Cache expiry
    cached_at = Column(DateTime, nullable=False, default=datetime.utcnow)
    expires_at = Column(DateTime, nullable=True)
    
    def is_expired(self):
        """Check if cache has expired."""
        if self.expires_at is None:
            return False
        return datetime.utcnow() > self.expires_at
    
    def __repr__(self):
        return f"<UserContextCache(user_id={self.user_id}, cached_at={self.cached_at})>"
