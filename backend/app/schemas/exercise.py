"""
Pydantic schemas for Exercise API.
"""

from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime
from enum import Enum


class ExerciseCategoryEnum(str, Enum):
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


class ExerciseDifficultyEnum(str, Enum):
    """Exercise difficulty levels."""
    easy = "easy"
    medium = "medium"
    hard = "hard"


# Exercise Schemas
class ExerciseCreate(BaseModel):
    """Schema for creating an exercise."""
    name: str
    description: Optional[str] = None
    category: ExerciseCategoryEnum
    difficulty: ExerciseDifficultyEnum = ExerciseDifficultyEnum.easy
    duration_seconds: int
    instructions: Optional[List[str]] = None
    benefits: Optional[List[str]] = None
    emoji: Optional[str] = None
    audio_url: Optional[str] = None
    video_url: Optional[str] = None
    is_featured: bool = False


class ExerciseUpdate(BaseModel):
    """Schema for updating an exercise."""
    name: Optional[str] = None
    description: Optional[str] = None
    category: Optional[ExerciseCategoryEnum] = None
    difficulty: Optional[ExerciseDifficultyEnum] = None
    duration_seconds: Optional[int] = None
    instructions: Optional[List[str]] = None
    benefits: Optional[List[str]] = None
    emoji: Optional[str] = None
    audio_url: Optional[str] = None
    video_url: Optional[str] = None
    is_featured: Optional[bool] = None
    is_active: Optional[bool] = None


class ExerciseStats(BaseModel):
    """Statistics about an exercise."""
    total_completions: int
    average_rating: float
    total_reviews: int


class ExerciseRead(BaseModel):
    """Schema for reading exercise data."""
    id: int
    name: str
    description: Optional[str]
    category: ExerciseCategoryEnum
    difficulty: ExerciseDifficultyEnum
    duration_seconds: int
    instructions: Optional[List[str]]
    benefits: Optional[List[str]]
    emoji: Optional[str]
    audio_url: Optional[str]
    video_url: Optional[str]
    total_completions: int
    average_rating: float
    total_reviews: int
    is_active: bool
    is_featured: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


# Exercise Session Schemas
class ExerciseSessionCreate(BaseModel):
    """Schema for starting an exercise session."""
    exercise_id: int
    mood_before: Optional[int] = Field(None, ge=1, le=10)
    energy_before: Optional[int] = Field(None, ge=1, le=10)
    stress_before: Optional[int] = Field(None, ge=1, le=10)


class ExerciseSessionComplete(BaseModel):
    """Schema for completing an exercise session."""
    mood_after: Optional[int] = Field(None, ge=1, le=10)
    energy_after: Optional[int] = Field(None, ge=1, le=10)
    stress_after: Optional[int] = Field(None, ge=1, le=10)
    rating: Optional[int] = Field(None, ge=1, le=5)
    review: Optional[str] = None
    notes: Optional[str] = None


class ExerciseSessionRead(BaseModel):
    """Schema for reading exercise session data."""
    id: int
    exercise_id: int
    mood_before: Optional[int]
    mood_after: Optional[int]
    energy_before: Optional[int]
    energy_after: Optional[int]
    stress_before: Optional[int]
    stress_after: Optional[int]
    started_at: datetime
    completed_at: Optional[datetime]
    duration_seconds: Optional[int]
    completed: bool
    rating: Optional[int]
    created_at: datetime

    class Config:
        from_attributes = True


class ExerciseSessionDetail(BaseModel):
    """Detailed schema for reading exercise session data."""
    id: int
    exercise: ExerciseRead
    mood_before: Optional[int]
    mood_after: Optional[int]
    energy_before: Optional[int]
    energy_after: Optional[int]
    stress_before: Optional[int]
    stress_after: Optional[int]
    started_at: datetime
    completed_at: Optional[datetime]
    duration_seconds: Optional[int]
    completed: bool
    rating: Optional[int]
    review: Optional[str]
    notes: Optional[str]
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


# User Statistics Schemas
class ExerciseStrengthArea(BaseModel):
    """Strength area based on user's exercise preferences."""
    category: ExerciseCategoryEnum
    completion_count: int
    average_rating: float


class UserExerciseStats(BaseModel):
    """User's overall exercise statistics."""
    current_streak: int
    longest_streak: int
    total_exercises_completed: int
    total_time_minutes: int
    mood_improvement: Optional[float] = None
    energy_improvement: Optional[float] = None
    stress_reduction: Optional[float] = None


class UserExerciseProgress(BaseModel):
    """User's exercise progress and recommendations."""
    stats: UserExerciseStats
    strength_areas: List[ExerciseStrengthArea]
    recommended_exercises: List[ExerciseRead]
    next_milestone: Optional[str] = None


# Favorites Schemas
class FavoriteExerciseCreate(BaseModel):
    """Schema for creating a favorite exercise."""
    exercise_id: int


class FavoriteExerciseRead(BaseModel):
    """Schema for reading favorite exercise data."""
    id: int
    exercise: ExerciseRead
    created_at: datetime

    class Config:
        from_attributes = True


# List Response Schemas
class ExerciseListResponse(BaseModel):
    """Schema for exercise list response with pagination."""
    items: List[ExerciseRead]
    total: int
    page: int
    page_size: int
    total_pages: int


class ExerciseSessionListResponse(BaseModel):
    """Schema for exercise session list response with pagination."""
    items: List[ExerciseSessionRead]
    total: int
    page: int
    page_size: int
    total_pages: int


# Category and Difficulty Schemas
class CategoryOption(BaseModel):
    """Category option for dropdown."""
    value: ExerciseCategoryEnum
    label: str


class DifficultyOption(BaseModel):
    """Difficulty option for dropdown."""
    value: ExerciseDifficultyEnum
    label: str
