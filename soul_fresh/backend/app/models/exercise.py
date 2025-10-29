from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Float, JSON, Text, Boolean, Enum as SQLEnum
from sqlalchemy.orm import relationship
from datetime import datetime
import enum
from app.database import Base


class ExerciseCategoryEnum(str, enum.Enum):
    """Exercise categories"""
    breathing = "breathing"
    progressive_muscle_relaxation = "progressive_muscle_relaxation"
    grounding = "grounding"
    cognitive_behavioral = "cognitive_behavioral"
    journaling = "journaling"
    visualization = "visualization"
    movement = "movement"
    anxiety = "anxiety"
    sleep = "sleep"
    emotional_regulation = "emotional_regulation"
    social_connection = "social_connection"
    gamification = "gamification"
    quick_relief = "quick_relief"


class ExerciseDifficultyEnum(str, enum.Enum):
    """Exercise difficulty levels"""
    easy = "easy"
    medium = "medium"
    hard = "hard"


class Exercise(Base):
    """Exercise model for database"""
    __tablename__ = "exercises"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    category = Column(SQLEnum(ExerciseCategoryEnum), nullable=False, index=True)
    difficulty = Column(SQLEnum(ExerciseDifficultyEnum), nullable=False)
    duration_seconds = Column(Integer, nullable=False)  # Duration in seconds
    description = Column(Text, nullable=False)
    instructions = Column(JSON, nullable=False)  # List of step-by-step instructions
    benefits = Column(JSON, nullable=False)  # List of benefits
    emoji = Column(String(10), nullable=False)
    audio_url = Column(String(500), nullable=True)
    video_url = Column(String(500), nullable=True)
    image_url = Column(String(500), nullable=True)
    
    # Statistics
    total_completions = Column(Integer, default=0, index=True)
    average_rating = Column(Float, default=0.0)
    total_reviews = Column(Integer, default=0)
    
    # Metadata
    created_at = Column(DateTime, default=datetime.utcnow, index=True)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    is_active = Column(Boolean, default=True, index=True)
    
    # Relationships
    sessions = relationship("ExerciseSession", back_populates="exercise", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<Exercise(id={self.id}, name={self.name}, category={self.category})>"


class ExerciseSession(Base):
    """User exercise session tracking"""
    __tablename__ = "exercise_sessions"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    exercise_id = Column(Integer, ForeignKey("exercises.id"), nullable=False, index=True)
    
    # Timing
    started_at = Column(DateTime, default=datetime.utcnow, index=True)
    completed_at = Column(DateTime, nullable=True)
    duration_seconds = Column(Integer, nullable=True)  # Actual duration completed
    
    # User feedback
    mood_before = Column(Integer, nullable=False)  # 1-10 scale
    mood_after = Column(Integer, nullable=True)  # 1-10 scale
    energy_before = Column(Integer, nullable=True)  # 1-10 scale
    energy_after = Column(Integer, nullable=True)  # 1-10 scale
    stress_before = Column(Integer, nullable=True)  # 1-10 scale
    stress_after = Column(Integer, nullable=True)  # 1-10 scale
    
    # Rating and feedback
    rating = Column(Integer, nullable=True)  # 1-5 stars
    review = Column(Text, nullable=True)
    notes = Column(Text, nullable=True)
    
    # Metadata
    completed = Column(Boolean, default=False, index=True)
    created_at = Column(DateTime, default=datetime.utcnow, index=True)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    exercise = relationship("Exercise", back_populates="sessions")

    def __repr__(self):
        return f"<ExerciseSession(id={self.id}, user_id={self.user_id}, exercise_id={self.exercise_id})>"


class ExerciseStreak(Base):
    """Track user exercise streaks"""
    __tablename__ = "exercise_streaks"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True, unique=True)
    
    current_streak = Column(Integer, default=0)  # Days in current streak
    longest_streak = Column(Integer, default=0)  # Longest streak ever
    last_session_date = Column(DateTime, nullable=True)
    total_exercises_completed = Column(Integer, default=0)
    total_time_minutes = Column(Integer, default=0)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    def __repr__(self):
        return f"<ExerciseStreak(user_id={self.user_id}, current_streak={self.current_streak})>"


class FavoriteExercise(Base):
    """Track user's favorite exercises"""
    __tablename__ = "favorite_exercises"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    exercise_id = Column(Integer, ForeignKey("exercises.id"), nullable=False, index=True)
    
    added_at = Column(DateTime, default=datetime.utcnow, index=True)

    def __repr__(self):
        return f"<FavoriteExercise(user_id={self.user_id}, exercise_id={self.exercise_id})>"
