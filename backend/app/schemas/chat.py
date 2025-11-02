"""
Pydantic schemas for chat API requests and responses.
Supports both legacy conversation model and new AI chat system.
"""

from pydantic import BaseModel, Field, field_validator
from datetime import datetime
from typing import List, Optional, Dict, Any
from enum import Enum


# ============================================================================
# Legacy conversation schemas (keep for backward compatibility)
# ============================================================================

class MessageIn(BaseModel):
    text: str
    conversation_id: int | None = None
    modality: str | None = None  # e.g. 'cbt', 'dbt', 'mindfulness'
    max_context_messages: int | None = 10


class MessageOut(BaseModel):
    id: int
    sender: str
    text: str
    created_at: datetime

    model_config = {"from_attributes": True}


class ConversationRead(BaseModel):
    id: int
    user_id: int
    messages: List[MessageOut]

    model_config = {"from_attributes": True}


# ============================================================================
# New AI Chat System schemas
# ============================================================================

class MessageRole(str, Enum):
    """Enum for message roles."""
    USER = "user"
    ASSISTANT = "assistant"
    SYSTEM = "system"


class ChatMessageRead(BaseModel):
    """Schema for reading a chat message."""
    id: str
    session_id: str
    role: str
    content: str
    tokens_used: Optional[int] = None
    model_used: Optional[str] = None
    streaming_completed: bool = False
    flagged_by_moderation: bool = False
    contains_crisis_keywords: bool = False
    response_time_ms: Optional[int] = None
    created_at: datetime

    class Config:
        from_attributes = True


class ChatSessionRead(BaseModel):
    """Schema for reading a chat session."""
    id: str
    user_id: int
    started_at: datetime
    ended_at: Optional[datetime] = None
    is_active: bool = True
    session_mood: Optional[str] = None
    session_intensity: Optional[int] = None
    session_triggers: List[str] = Field(default_factory=list)
    total_messages: int = 0
    is_crisis_escalated: bool = False
    created_at: datetime
    updated_at: datetime
    messages: List[ChatMessageRead] = Field(default_factory=list)

    class Config:
        from_attributes = True


class ChatRequest(BaseModel):
    """Schema for incoming chat messages from client."""
    message: str = Field(..., min_length=1, max_length=2000)
    session_id: Optional[str] = None
    include_context: bool = True

    @field_validator('message')
    @classmethod
    def validate_message(cls, v):
        """Ensure message is not empty after stripping."""
        if not v or len(v.strip()) == 0:
            raise ValueError('Message cannot be empty')
        return v.strip()


class ChatResponse(BaseModel):
    """Schema for chat response to client."""
    session_id: str
    message_id: str
    content: str
    suggestions: List[str] = Field(default_factory=list)
    is_crisis_detected: bool = False
    crisis_resources: Optional[Dict[str, Any]] = None
    response_time_ms: Optional[int] = None


class StreamToken(BaseModel):
    """Schema for streaming token in SSE response."""
    token: str
    done: bool = False
    message_id: Optional[str] = None
    error: Optional[str] = None


class CrisisResourcesRead(BaseModel):
    """Schema for crisis resources."""
    suicide_prevention: Dict[str, str]
    emergency: Dict[str, str]
    crisis_text: Dict[str, str]


class CrisisResponseSchema(BaseModel):
    """Schema for crisis detection response."""
    is_crisis: bool
    message: str
    resources: CrisisResourcesRead
    immediate_actions: List[str]


class UserContextRead(BaseModel):
    """Schema for user context used in AI personalization."""
    user_id: int
    latest_mood: Optional[str] = None
    mood_intensity: Optional[int] = None
    recent_triggers: List[str] = Field(default_factory=list)
    completed_activities: List[str] = Field(default_factory=list)
    active_pathways: List[str] = Field(default_factory=list)
    assessment_scores: Dict[str, float] = Field(default_factory=dict)


class ModerationLogRead(BaseModel):
    """Schema for reading moderation logs."""
    id: str
    message_id: Optional[str] = None
    user_id: int
    flagged_content: str
    moderation_reason: str
    severity_level: str
    human_reviewed: bool
    reviewer_notes: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True


class SessionHistoryRead(BaseModel):
    """Schema for session history list."""
    id: str
    started_at: datetime
    ended_at: Optional[datetime] = None
    session_mood: Optional[str] = None
    session_intensity: Optional[int] = None
    total_messages: int = 0
    is_crisis_escalated: bool = False

    class Config:
        from_attributes = True
