from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime
from enum import Enum


class ExerciseCategoryEnum(str, Enum):
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


class ExerciseDifficultyEnum(str, Enum):
    """Exercise difficulty levels"""
    easy = "easy"
    medium = "medium"
    hard = "hard"


# ===== EXERCISE SCHEMAS =====

class ExerciseBase(BaseModel):
    """Base exercise schema"""
    name: str
    category: ExerciseCategoryEnum
    difficulty: ExerciseDifficultyEnum
    duration_seconds: int
    description: str
    instructions: List[str]
    benefits: List[str]
    emoji: str
    audio_url: Optional[str] = None
    video_url: Optional[str] = None
    image_url: Optional[str] = None


class ExerciseCreate(ExerciseBase):
    """Create exercise schema"""
    pass


class ExerciseUpdate(BaseModel):
    """Update exercise schema"""
    name: Optional[str] = None
    description: Optional[str] = None
    instructions: Optional[List[str]] = None
    benefits: Optional[List[str]] = None
    is_active: Optional[bool] = None


class ExerciseRead(ExerciseBase):
    """Read exercise schema"""
    id: int
    total_completions: int = 0
    average_rating: float = 0.0
    total_reviews: int = 0
    created_at: datetime
    updated_at: datetime
    is_active: bool

    class Config:
        from_attributes = True


class ExerciseStats(BaseModel):
    """Exercise statistics"""
    exercise_id: int
    exercise_name: str
    total_completions: int
    average_rating: float
    total_reviews: int
    average_mood_improvement: float  # mood_after - mood_before
    average_duration: float  # Average actual duration vs intended
    favorite_count: int


# ===== EXERCISE SESSION SCHEMAS =====

class ExerciseSessionCreate(BaseModel):
    """Create exercise session"""
    exercise_id: int
    mood_before: int = Field(ge=1, le=10)
    energy_before: Optional[int] = Field(None, ge=1, le=10)
    stress_before: Optional[int] = Field(None, ge=1, le=10)


class ExerciseSessionComplete(BaseModel):
    """Complete exercise session"""
    duration_seconds: int
    mood_after: Optional[int] = Field(None, ge=1, le=10)
    energy_after: Optional[int] = Field(None, ge=1, le=10)
    stress_after: Optional[int] = Field(None, ge=1, le=10)
    rating: Optional[int] = Field(None, ge=1, le=5)
    review: Optional[str] = None
    notes: Optional[str] = None


class ExerciseSessionRead(BaseModel):
    """Read exercise session"""
    id: int
    user_id: int
    exercise_id: int
    started_at: datetime
    completed_at: Optional[datetime]
    duration_seconds: Optional[int]
    mood_before: int
    mood_after: Optional[int]
    energy_before: Optional[int]
    energy_after: Optional[int]
    stress_before: Optional[int]
    stress_after: Optional[int]
    rating: Optional[int]
    review: Optional[str]
    notes: Optional[str]
    completed: bool
    created_at: datetime

    class Config:
        from_attributes = True


class ExerciseSessionDetail(ExerciseSessionRead):
    """Detailed exercise session with exercise info"""
    exercise: ExerciseRead


# ===== USER STATS SCHEMAS =====

class UserExerciseStats(BaseModel):
    """User's exercise statistics"""
    total_exercises_completed: int
    total_time_minutes: int
    current_streak: int
    longest_streak: int
    average_mood_improvement: float
    average_rating: float
    favorite_exercises_count: int
    exercises_this_week: int
    exercises_this_month: int


class ExerciseStrengthArea(BaseModel):
    """Area where user excels in exercises"""
    category: str
    exercises_completed: int
    average_rating: float


class UserExerciseProgress(BaseModel):
    """User's exercise progress"""
    stats: UserExerciseStats
    strength_areas: List[ExerciseStrengthArea]
    recommended_exercises: List[ExerciseRead]


# ===== FAVORITE EXERCISE SCHEMAS =====

class FavoriteExerciseCreate(BaseModel):
    """Add favorite exercise"""
    exercise_id: int


class FavoriteExerciseRead(BaseModel):
    """Read favorite exercise"""
    id: int
    user_id: int
    exercise_id: int
    added_at: datetime

    class Config:
        from_attributes = True


# ===== LIST RESPONSE SCHEMAS =====

class ExerciseListResponse(BaseModel):
    """List of exercises with pagination"""
    items: List[ExerciseRead]
    total: int
    page: int
    per_page: int
    pages: int


class ExerciseSessionListResponse(BaseModel):
    """List of exercise sessions"""
    items: List[ExerciseSessionRead]
    total: int
    page: int
    per_page: int
    pages: int
