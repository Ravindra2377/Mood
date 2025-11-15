"""
SQLAlchemy models for Exercise system.
"""

from sqlalchemy import Column, Integer, String, Text, Float, DateTime, Boolean, ForeignKey, JSON, Enum as SQLEnum
from sqlalchemy.orm import relationship
from datetime import datetime
import enum

from app.models import Base


class ExerciseCategoryEnum(str, enum.Enum):
    """Exercise categories."""
    breathing = "breathing"
    progressive_muscle_relaxation = "pmr"
    grounding = "grounding"
    cognitive_behavioral = "cbt"
    journaling = "journaling"
    visualization = "visualization"
    movement = "movement"
    anxiety = "anxiety"
    sleep = "sleep"
    emotional_regulation = "emotional"
    social_connection = "social"
    gamification = "games"
    quick_relief = "quick_relief"


class ExerciseDifficultyEnum(str, enum.Enum):
    """Exercise difficulty levels."""
    easy = "easy"
    medium = "medium"
    hard = "hard"


class Exercise(Base):
    """Represents an exercise in the mental health program."""
    __tablename__ = "exercises"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False, unique=True)
    description = Column(Text, nullable=True)
    category = Column(SQLEnum(ExerciseCategoryEnum), nullable=False, index=True)
    difficulty = Column(SQLEnum(ExerciseDifficultyEnum), nullable=False, default=ExerciseDifficultyEnum.easy)
    duration_seconds = Column(Integer, nullable=False)  # Duration in seconds
    
    # Content
    instructions = Column(JSON, nullable=True)  # List of instruction steps
    benefits = Column(JSON, nullable=True)  # List of benefits
    emoji = Column(String(10), nullable=True)
    audio_url = Column(String(255), nullable=True)
    video_url = Column(String(255), nullable=True)
    
    # Statistics
    total_completions = Column(Integer, default=0)
    average_rating = Column(Float, default=0.0)
    total_reviews = Column(Integer, default=0)
    
    # Status
    is_active = Column(Boolean, default=True)
    is_featured = Column(Boolean, default=False)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    sessions = relationship("ExerciseSession", back_populates="exercise")
    favorites = relationship("FavoriteExercise", back_populates="exercise")


class ExerciseSession(Base):
    """Represents a user's exercise session."""
    __tablename__ = "exercise_sessions"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    exercise_id = Column(Integer, ForeignKey("exercises.id"), nullable=False, index=True)
    
    # Mood tracking before/after
    mood_before = Column(Integer, nullable=True)  # 1-10
    mood_after = Column(Integer, nullable=True)  # 1-10
    energy_before = Column(Integer, nullable=True)  # 1-10
    energy_after = Column(Integer, nullable=True)  # 1-10
    stress_before = Column(Integer, nullable=True)  # 1-10
    stress_after = Column(Integer, nullable=True)  # 1-10
    
    # Session details
    started_at = Column(DateTime, default=datetime.utcnow)
    completed_at = Column(DateTime, nullable=True)
    duration_seconds = Column(Integer, nullable=True)
    
    # User feedback
    completed = Column(Boolean, default=False)
    rating = Column(Integer, nullable=True)  # 1-5 stars
    review = Column(Text, nullable=True)
    notes = Column(Text, nullable=True)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    exercise = relationship("Exercise", back_populates="sessions")


class ExerciseStreak(Base):
    """Track user's exercise streaks and statistics."""
    __tablename__ = "exercise_streaks"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False, index=True)
    
    current_streak = Column(Integer, default=0)
    longest_streak = Column(Integer, default=0)
    last_session_date = Column(DateTime, nullable=True)
    
    # Totals
    total_exercises_completed = Column(Integer, default=0)
    total_time_minutes = Column(Integer, default=0)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class FavoriteExercise(Base):
    """Track user's favorite exercises."""
    __tablename__ = "favorite_exercises"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    exercise_id = Column(Integer, ForeignKey("exercises.id"), nullable=False, index=True)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    exercise = relationship("Exercise", back_populates="favorites")
