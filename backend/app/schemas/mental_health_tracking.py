"""
Pydantic schemas for Mental Health Tracking API endpoints.
Used for request/response validation.
"""

from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from datetime import datetime
from enum import Enum


# ===========================
# ENUMS
# ===========================

class GoalCategoryEnum(str, Enum):
    MANAGING_STRESS = "managing_stress"
    IMPROVING_MOOD = "improving_mood"
    BETTER_SLEEP = "better_sleep"
    MINDFULNESS = "mindfulness"
    COPING_ANXIETY = "coping_anxiety"
    GENERAL_WELLNESS = "general_wellness"


class StressExerciseType(str, Enum):
    BREATHING = "breathing"
    MUSCLE_RELAXATION = "muscle_relaxation"
    MEDITATION = "meditation"
    GROUNDING = "grounding"
    JOURNALING = "journaling"


class MoodActivityType(str, Enum):
    MUSIC = "music"
    EXERCISE = "exercise"
    SOCIALIZING = "socializing"
    NATURE = "nature"
    CREATIVE = "creative"
    READING = "reading"
    GAMING = "gaming"


class AnxietyIntensity(str, Enum):
    MILD = "mild"
    MODERATE = "moderate"
    SEVERE = "severe"


class MeditationType(str, Enum):
    GUIDED = "guided"
    BODY_SCAN = "body_scan"
    BREATHING = "breathing"
    LOVING_KINDNESS = "loving_kindness"
    WALKING = "walking"
    VISUALIZATION = "visualization"


# ===========================
# STRESS MANAGEMENT SCHEMAS
# ===========================

class StressLogCreate(BaseModel):
    level: int = Field(..., ge=1, le=10, description="Stress level 1-10")
    triggers: List[str] = Field(default=[], description="List of stress triggers")
    notes: Optional[str] = None

    class Config:
        schema_extra = {
            "example": {
                "level": 7,
                "triggers": ["work deadline", "family issue"],
                "notes": "Feeling overwhelmed with projects"
            }
        }


class StressLogResponse(StressLogCreate):
    id: int
    user_id: int
    timestamp: datetime
    created_at: datetime

    class Config:
        from_attributes = True


class StressExerciseCreate(BaseModel):
    exercise_type: StressExerciseType
    exercise_name: str
    duration_seconds: Optional[int] = None
    effectiveness_rating: Optional[int] = Field(None, ge=1, le=5)
    notes: Optional[str] = None


class StressExerciseResponse(StressExerciseCreate):
    id: int
    user_id: int
    completed_at: datetime
    created_at: datetime

    class Config:
        from_attributes = True


class StressJournalEntryCreate(BaseModel):
    title: str
    content: str
    stress_level_before: Optional[int] = Field(None, ge=1, le=10)
    stress_level_after: Optional[int] = Field(None, ge=1, le=10)
    triggers: List[str] = Field(default=[])
    coping_strategies_used: List[str] = Field(default=[])


class StressJournalEntryResponse(StressJournalEntryCreate):
    id: int
    user_id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class StressTrendsResponse(BaseModel):
    average_level: float
    trend: str  # "increasing", "decreasing", "stable"
    most_common_triggers: List[str]
    most_effective_exercises: List[Dict[str, Any]]
    period: str  # "daily", "weekly", "monthly"
    data_points: int


# ===========================
# MOOD TRACKING SCHEMAS
# ===========================

class MoodActivityCreate(BaseModel):
    activity_type: MoodActivityType
    activity_name: str
    mood_before: Optional[int] = Field(None, ge=1, le=10)
    mood_after: Optional[int] = Field(None, ge=1, le=10)
    duration_minutes: Optional[int] = None
    effectiveness_rating: Optional[int] = Field(None, ge=1, le=5)
    notes: Optional[str] = None


class MoodActivityResponse(MoodActivityCreate):
    id: int
    user_id: int
    completed_at: datetime
    created_at: datetime

    class Config:
        from_attributes = True


class GratitudeEntryCreate(BaseModel):
    content: str = Field(..., min_length=10, description="What user is grateful for")
    mood_before: Optional[int] = Field(None, ge=1, le=10)
    category: Optional[str] = None


class GratitudeEntryResponse(GratitudeEntryCreate):
    id: int
    user_id: int
    mood_after: Optional[int]
    created_at: datetime

    class Config:
        from_attributes = True


class MoodCorrelationResponse(BaseModel):
    factor_type: str
    factor_value: str
    correlation_score: float
    data_points: int


class MoodInsightsResponse(BaseModel):
    average_mood: float
    mood_trend: str  # "improving", "declining", "stable"
    top_activities: List[Dict[str, Any]]
    correlations: List[MoodCorrelationResponse]
    recent_entries: int
    period: str


# ===========================
# SLEEP TRACKING SCHEMAS
# ===========================

class SleepLogCreate(BaseModel):
    bedtime: datetime
    wake_time: datetime
    quality_rating: Optional[int] = Field(None, ge=1, le=5)
    notes: Optional[str] = None


class SleepLogResponse(SleepLogCreate):
    id: int
    user_id: int
    duration_hours: float
    created_at: datetime

    class Config:
        from_attributes = True


class SleepFactorCreate(BaseModel):
    date: datetime
    caffeine_intake: Optional[float] = None  # mg
    alcohol_intake: Optional[float] = None  # standard drinks
    exercise_minutes: Optional[int] = None
    screen_time_minutes: Optional[int] = None
    stress_level: Optional[int] = Field(None, ge=1, le=10)
    notes: Optional[str] = None


class SleepFactorResponse(SleepFactorCreate):
    id: int
    user_id: int
    created_at: datetime

    class Config:
        from_attributes = True


class SleepMeditationCreate(BaseModel):
    meditation_id: str
    title: str
    duration_seconds: int
    fell_asleep: bool = False
    quality_rating: Optional[int] = Field(None, ge=1, le=5)


class SleepMeditationResponse(SleepMeditationCreate):
    id: int
    user_id: int
    completed_at: datetime
    created_at: datetime

    class Config:
        from_attributes = True


class SleepTrendsResponse(BaseModel):
    average_duration: float
    average_quality: float
    trend: str  # "improving", "declining", "stable"
    factors_affecting_sleep: List[Dict[str, Any]]
    sleep_debt_hours: float
    optimal_duration_recommendation: float
    period: str


# ===========================
# MINDFULNESS SCHEMAS
# ===========================

class MeditationSessionCreate(BaseModel):
    meditation_type: MeditationType
    meditation_id: str
    title: str
    duration_seconds: int
    mood_before: Optional[int] = Field(None, ge=1, le=10)
    focus_level: Optional[int] = Field(None, ge=1, le=5)
    notes: Optional[str] = None


class MeditationSessionResponse(MeditationSessionCreate):
    id: int
    user_id: int
    mood_after: Optional[int]
    completed_at: datetime
    created_at: datetime

    class Config:
        from_attributes = True


class MeditationContentCreate(BaseModel):
    title: str
    description: Optional[str] = None
    meditation_type: MeditationType
    duration_seconds: int
    category: str
    audio_url: str
    thumbnail_url: Optional[str] = None
    instructor_name: Optional[str] = None
    difficulty_level: str = "beginner"
    language: str = "en"


class MeditationContentResponse(MeditationContentCreate):
    id: int
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True


class MindfulnessStatsResponse(BaseModel):
    total_sessions: int
    total_minutes_meditated: float
    current_streak: int
    longest_streak: int
    average_session_duration: float
    most_practiced_type: str
    last_session: Optional[datetime]
    mood_improvement: Optional[float]


class MindfulnessAchievementResponse(BaseModel):
    id: int
    achievement_type: str
    achievement_name: str
    description: Optional[str]
    unlocked_at: datetime

    class Config:
        from_attributes = True


# ===========================
# ANXIETY MANAGEMENT SCHEMAS
# ===========================

class AnxietyLogCreate(BaseModel):
    level: int = Field(..., ge=1, le=10)
    triggers: List[str] = Field(default=[])
    symptoms: List[str] = Field(default=[])
    duration_minutes: Optional[int] = None
    intensity: AnxietyIntensity
    is_panic_attack: bool = False
    notes: Optional[str] = None


class AnxietyLogResponse(AnxietyLogCreate):
    id: int
    user_id: int
    created_at: datetime

    class Config:
        from_attributes = True


class AnxietyCopingTechniqueCreate(BaseModel):
    technique_name: str
    technique_type: str  # physical, mental, behavioral
    description: Optional[str] = None
    duration_minutes: Optional[int] = None
    effectiveness_rating: Optional[int] = Field(None, ge=1, le=5)
    anxiety_level_before: Optional[int] = Field(None, ge=1, le=10)
    anxiety_level_after: Optional[int] = Field(None, ge=1, le=10)


class AnxietyCopingTechniqueResponse(AnxietyCopingTechniqueCreate):
    id: int
    user_id: int
    used_at: datetime
    created_at: datetime

    class Config:
        from_attributes = True


class SafetyPlanCreate(BaseModel):
    warning_signs: Optional[List[str]] = None
    internal_coping: Optional[List[str]] = None
    people_to_contact: Optional[List[Dict[str, str]]] = None
    professional_contacts: Optional[List[Dict[str, str]]] = None
    crisis_hotlines: Optional[List[Dict[str, str]]] = None
    ways_to_make_environment_safer: Optional[List[str]] = None
    plan_content: Optional[str] = None


class SafetyPlanResponse(SafetyPlanCreate):
    id: int
    user_id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class CrisisAlertResponse(BaseModel):
    id: int
    user_id: int
    alert_level: str
    trigger_reason: str
    description: Optional[str]
    intervention_provided: Optional[str]
    is_resolved: bool
    triggered_at: datetime

    class Config:
        from_attributes = True


# ===========================
# WELLNESS SCHEMAS
# ===========================

class WellnessScoreResponse(BaseModel):
    id: int
    user_id: int
    date: datetime
    overall_score: float
    stress_score: Optional[float]
    mood_score: Optional[float]
    sleep_score: Optional[float]
    anxiety_score: Optional[float]
    exercise_score: Optional[float]
    social_score: Optional[float]
    nutrition_score: Optional[float]

    class Config:
        from_attributes = True


class LifestyleLogCreate(BaseModel):
    activity_type: str
    activity_name: str
    value: Optional[float] = None
    unit: Optional[str] = None
    intensity: Optional[str] = None
    notes: Optional[str] = None


class LifestyleLogResponse(LifestyleLogCreate):
    id: int
    user_id: int
    logged_at: datetime
    created_at: datetime

    class Config:
        from_attributes = True


class WellnessGoalCreate(BaseModel):
    goal_type: str
    goal_name: str
    target_value: float
    unit: str
    timeframe: str  # daily, weekly, monthly
    deadline: Optional[datetime] = None


class WellnessGoalResponse(WellnessGoalCreate):
    id: int
    user_id: int
    current_value: float
    progress_percentage: float
    is_active: bool
    is_completed: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class DailyCheckinCreate(BaseModel):
    date: datetime
    mood: Optional[int] = Field(None, ge=1, le=10)
    energy: Optional[int] = Field(None, ge=1, le=10)
    stress: Optional[int] = Field(None, ge=1, le=10)
    sleep_quality: Optional[int] = Field(None, ge=1, le=5)
    overall_wellness: Optional[int] = Field(None, ge=1, le=10)
    notes: Optional[str] = None


class DailyCheckinResponse(DailyCheckinCreate):
    id: int
    user_id: int
    created_at: datetime

    class Config:
        from_attributes = True


class UserGoalSelectionCreate(BaseModel):
    goal_categories: List[GoalCategoryEnum]
    customization_preferences: Optional[Dict[str, Any]] = None


class UserGoalSelectionResponse(UserGoalSelectionCreate):
    id: int
    user_id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class WellnessInsightsResponse(BaseModel):
    overall_score: float
    overall_trend: str
    category_insights: Dict[str, Any]
    recommendations: List[str]
    top_factors_affecting_wellness: List[Dict[str, Any]]
    goals_progress: List[WellnessGoalResponse]
    period: str
