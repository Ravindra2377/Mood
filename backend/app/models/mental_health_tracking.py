"""
Mental Health Tracking Models for all wellness goal categories.
Includes: Stress, Mood, Sleep, Mindfulness, Anxiety, Wellness
"""

from sqlalchemy import Column, Integer, String, Float, DateTime, Boolean, Text, JSON, ForeignKey, Enum
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
from app.models import Base
import enum


class GoalCategory(str, enum.Enum):
    """Mental health goal categories."""
    MANAGING_STRESS = "managing_stress"
    IMPROVING_MOOD = "improving_mood"
    BETTER_SLEEP = "better_sleep"
    MINDFULNESS = "mindfulness"
    COPING_ANXIETY = "coping_anxiety"
    GENERAL_WELLNESS = "general_wellness"


# ===========================
# 1. STRESS MANAGEMENT MODELS
# ===========================

class StressLog(Base):
    """Track user's daily stress levels and triggers."""
    __tablename__ = 'stress_logs'
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False, index=True)
    level = Column(Integer, nullable=False)  # 1-10 scale
    triggers = Column(JSON, default=list)  # List of stress triggers
    notes = Column(Text, nullable=True)
    timestamp = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), index=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    
    # Relationships
    user = relationship("User", back_populates="stress_logs")


class StressExercise(Base):
    """Track completed stress relief exercises."""
    __tablename__ = 'stress_exercises'
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False, index=True)
    exercise_type = Column(String, nullable=False)  # breathing, muscle_relaxation, etc.
    exercise_name = Column(String, nullable=False)
    duration_seconds = Column(Integer, nullable=True)  # Duration in seconds
    effectiveness_rating = Column(Integer, nullable=True)  # 1-5 scale
    notes = Column(Text, nullable=True)
    completed_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), index=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    
    user = relationship("User", back_populates="stress_exercises")


class StressJournalEntry(Base):
    """Dedicated stress journal entries with prompts."""
    __tablename__ = 'stress_journal_entries'
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False, index=True)
    title = Column(String, nullable=False)
    content = Column(Text, nullable=False)
    stress_level_before = Column(Integer, nullable=True)  # 1-10
    stress_level_after = Column(Integer, nullable=True)  # 1-10
    triggers = Column(JSON, default=list)  # Associated triggers
    coping_strategies_used = Column(JSON, default=list)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), index=True)
    updated_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    
    user = relationship("User", back_populates="stress_journal_entries")


# ===========================
# 2. MOOD TRACKING MODELS
# ===========================

class MoodActivity(Base):
    """Track mood-boosting activities and their effectiveness."""
    __tablename__ = 'mood_activities'
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False, index=True)
    activity_type = Column(String, nullable=False)  # music, exercise, socializing, etc.
    activity_name = Column(String, nullable=False)
    mood_before = Column(Integer, nullable=True)  # 1-10
    mood_after = Column(Integer, nullable=True)  # 1-10
    duration_minutes = Column(Integer, nullable=True)
    effectiveness_rating = Column(Integer, nullable=True)  # 1-5
    notes = Column(Text, nullable=True)
    completed_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), index=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    
    user = relationship("User", back_populates="mood_activities")


class MoodCorrelation(Base):
    """Store correlations between mood and lifestyle factors."""
    __tablename__ = 'mood_correlations'
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False, index=True)
    factor_type = Column(String, nullable=False)  # sleep, exercise, weather, social, etc.
    factor_value = Column(String, nullable=False)  # e.g., "good_sleep", "outdoor_time"
    correlation_score = Column(Float, nullable=True)  # -1.0 to 1.0
    data_points = Column(Integer, default=0)  # Number of observations
    last_updated = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    
    user = relationship("User", back_populates="mood_correlations")


class GratitudeEntry(Base):
    """Gratitude journal for mood improvement."""
    __tablename__ = 'gratitude_entries'
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False, index=True)
    content = Column(Text, nullable=False)  # What user is grateful for
    mood_before = Column(Integer, nullable=True)
    mood_after = Column(Integer, nullable=True)
    category = Column(String, nullable=True)  # health, relationships, work, etc.
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), index=True)
    
    user = relationship("User", back_populates="gratitude_entries")


# ===========================
# 3. SLEEP TRACKING MODELS
# ===========================

class SleepLog(Base):
    """Track sleep duration and quality."""
    __tablename__ = 'sleep_logs'
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False, index=True)
    bedtime = Column(DateTime(timezone=True), nullable=False)
    wake_time = Column(DateTime(timezone=True), nullable=False)
    duration_hours = Column(Float, nullable=True)  # Calculated from bedtime/wake_time
    quality_rating = Column(Integer, nullable=True)  # 1-5 stars
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), index=True)
    
    user = relationship("User", back_populates="sleep_logs")


class SleepFactor(Base):
    """Track factors affecting sleep."""
    __tablename__ = 'sleep_factors'
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False, index=True)
    date = Column(DateTime(timezone=True), nullable=False, index=True)
    caffeine_intake = Column(Float, nullable=True)  # mg
    alcohol_intake = Column(Float, nullable=True)  # standard drinks
    exercise_minutes = Column(Integer, nullable=True)
    screen_time_minutes = Column(Integer, nullable=True)
    stress_level = Column(Integer, nullable=True)  # 1-10
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    
    user = relationship("User", back_populates="sleep_factors")


class SleepMeditation(Base):
    """Track sleep meditation sessions."""
    __tablename__ = 'sleep_meditations'
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False, index=True)
    meditation_id = Column(String, nullable=False)  # Reference to meditation content
    title = Column(String, nullable=False)
    duration_seconds = Column(Integer, nullable=False)
    fell_asleep = Column(Boolean, default=False)  # Did they fall asleep?
    quality_rating = Column(Integer, nullable=True)  # 1-5
    completed_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), index=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    
    user = relationship("User", back_populates="sleep_meditations")


# ===========================
# 4. MINDFULNESS MODELS
# ===========================

class MeditationSession(Base):
    """Track meditation sessions."""
    __tablename__ = 'meditation_sessions'
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False, index=True)
    meditation_type = Column(String, nullable=False)  # guided, body_scan, breathing, etc.
    meditation_id = Column(String, nullable=False)  # Reference to meditation content
    title = Column(String, nullable=False)
    duration_seconds = Column(Integer, nullable=False)
    mood_before = Column(Integer, nullable=True)  # 1-10
    mood_after = Column(Integer, nullable=True)  # 1-10
    focus_level = Column(Integer, nullable=True)  # 1-5 how well they focused
    notes = Column(Text, nullable=True)
    completed_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), index=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    
    user = relationship("User", back_populates="meditation_sessions")


class MindfulnessAchievement(Base):
    """Track mindfulness achievements and streaks."""
    __tablename__ = 'mindfulness_achievements'
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False, index=True)
    achievement_type = Column(String, nullable=False)  # streak_7, streak_30, total_hours_100, etc.
    achievement_name = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    unlocked_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), index=True)
    
    user = relationship("User", back_populates="mindfulness_achievements")


class MeditationContent(Base):
    """Store meditation content library."""
    __tablename__ = 'meditation_content'
    
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    meditation_type = Column(String, nullable=False)  # guided, body_scan, breathing, etc.
    duration_seconds = Column(Integer, nullable=False)
    category = Column(String, nullable=False)  # sleep, stress, focus, anxiety, etc.
    audio_url = Column(String, nullable=False)
    thumbnail_url = Column(String, nullable=True)
    instructor_name = Column(String, nullable=True)
    difficulty_level = Column(String, default="beginner")  # beginner, intermediate, advanced
    language = Column(String, default="en")
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    is_active = Column(Boolean, default=True)
    
    # Relationship removed until meditation_session.meditation_id stores an FK into meditation_content


# ===========================
# 5. ANXIETY MANAGEMENT MODELS
# ===========================

class AnxietyLog(Base):
    """Track anxiety episodes and patterns."""
    __tablename__ = 'anxiety_logs'
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False, index=True)
    level = Column(Integer, nullable=False)  # 1-10 scale
    triggers = Column(JSON, default=list)  # Array of anxiety triggers
    symptoms = Column(JSON, default=list)  # Physical symptoms: racing_heart, sweating, etc.
    duration_minutes = Column(Integer, nullable=True)
    intensity = Column(String, nullable=False)  # mild, moderate, severe
    is_panic_attack = Column(Boolean, default=False)
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), index=True)
    
    user = relationship("User", back_populates="anxiety_logs")


class AnxietyCopingTechnique(Base):
    """Track coping techniques used for anxiety."""
    __tablename__ = 'anxiety_coping_techniques'
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False, index=True)
    technique_name = Column(String, nullable=False)  # breathing, grounding, etc.
    technique_type = Column(String, nullable=False)  # physical, mental, behavioral
    description = Column(Text, nullable=True)
    duration_minutes = Column(Integer, nullable=True)
    effectiveness_rating = Column(Integer, nullable=True)  # 1-5
    anxiety_level_before = Column(Integer, nullable=True)
    anxiety_level_after = Column(Integer, nullable=True)
    used_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), index=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    
    user = relationship("User", back_populates="anxiety_coping_techniques")


class SafetyPlan(Base):
    """Store user's personalized safety/crisis plan."""
    __tablename__ = 'safety_plans'
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False, index=True, unique=True)
    warning_signs = Column(JSON, nullable=True)  # Signs crisis might be coming
    internal_coping = Column(JSON, nullable=True)  # Coping strategies to use alone
    people_to_contact = Column(JSON, nullable=True)  # Friends/family to reach out to
    professional_contacts = Column(JSON, nullable=True)  # Therapist, doctor info
    crisis_hotlines = Column(JSON, nullable=True)  # Emergency numbers
    ways_to_make_environment_safer = Column(JSON, nullable=True)  # Remove harmful items
    plan_content = Column(Text, nullable=True)  # Full safety plan text
    updated_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    
    user = relationship("User", back_populates="safety_plan")


# ===========================
# 6. GENERAL WELLNESS MODELS
# ===========================

class WellnessScore(Base):
    """Calculate and store overall wellness scores."""
    __tablename__ = 'wellness_scores'
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False, index=True)
    date = Column(DateTime(timezone=True), nullable=False, index=True)
    overall_score = Column(Float, nullable=False)  # 0-100
    stress_score = Column(Float, nullable=True)  # Component scores
    mood_score = Column(Float, nullable=True)
    sleep_score = Column(Float, nullable=True)
    anxiety_score = Column(Float, nullable=True)
    exercise_score = Column(Float, nullable=True)
    social_score = Column(Float, nullable=True)
    nutrition_score = Column(Float, nullable=True)
    component_scores = Column(JSON, nullable=True)  # Detailed breakdown
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    
    user = relationship("User", back_populates="wellness_scores")


class LifestyleLog(Base):
    """Track lifestyle activities and behaviors."""
    __tablename__ = 'lifestyle_logs'
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False, index=True)
    activity_type = Column(String, nullable=False)  # exercise, nutrition, social, screen_time, etc.
    activity_name = Column(String, nullable=False)
    value = Column(Float, nullable=True)  # Numeric value (minutes, calories, etc.)
    unit = Column(String, nullable=True)  # minutes, calories, servings, etc.
    intensity = Column(String, nullable=True)  # low, moderate, high
    notes = Column(Text, nullable=True)
    logged_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), index=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    
    user = relationship("User", back_populates="lifestyle_logs")


class WellnessGoal(Base):
    """Store user's wellness goals and progress."""
    __tablename__ = 'wellness_goals'
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False, index=True)
    goal_type = Column(String, nullable=False)  # exercise, sleep, meditation, etc.
    goal_name = Column(String, nullable=False)
    target_value = Column(Float, nullable=False)
    current_value = Column(Float, default=0)
    unit = Column(String, nullable=False)
    timeframe = Column(String, nullable=False)  # daily, weekly, monthly
    deadline = Column(DateTime(timezone=True), nullable=True)
    progress_percentage = Column(Float, default=0)
    is_active = Column(Boolean, default=True)
    is_completed = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    
    user = relationship("User", back_populates="wellness_goals")


class DailyCheckin(Base):
    """Daily wellness check-in data."""
    __tablename__ = 'daily_checkins'
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False, index=True)
    date = Column(DateTime(timezone=True), nullable=False, index=True)
    mood = Column(Integer, nullable=True)  # 1-10
    energy = Column(Integer, nullable=True)  # 1-10
    stress = Column(Integer, nullable=True)  # 1-10
    sleep_quality = Column(Integer, nullable=True)  # 1-5
    overall_wellness = Column(Integer, nullable=True)  # 1-10
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), index=True)
    
    user = relationship("User", back_populates="daily_checkins")


class UserGoalSelection(Base):
    """Track which goal categories user has selected."""
    __tablename__ = 'user_goal_selections'
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False, index=True, unique=True)
    goal_categories = Column(JSON, default=list)  # List of GoalCategory enums selected
    customization_preferences = Column(JSON, nullable=True)  # User's preferences for each goal
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    
    user = relationship("User", back_populates="goal_selections")


# Add relationships to User model (in models/__init__.py, these need to be added to User class):
# stress_logs = relationship("StressLog", back_populates="user")
# stress_exercises = relationship("StressExercise", back_populates="user")
# stress_journal_entries = relationship("StressJournalEntry", back_populates="user")
# mood_activities = relationship("MoodActivity", back_populates="user")
# mood_correlations = relationship("MoodCorrelation", back_populates="user")
# gratitude_entries = relationship("GratitudeEntry", back_populates="user")
# sleep_logs = relationship("SleepLog", back_populates="user")
# sleep_factors = relationship("SleepFactor", back_populates="user")
# sleep_meditations = relationship("SleepMeditation", back_populates="user")
# meditation_sessions = relationship("MeditationSession", back_populates="user")
# mindfulness_achievements = relationship("MindfulnessAchievement", back_populates="user")
# anxiety_logs = relationship("AnxietyLog", back_populates="user")
# anxiety_coping_techniques = relationship("AnxietyCopingTechnique", back_populates="user")
# safety_plan = relationship("SafetyPlan", back_populates="user", uselist=False)
# crisis_alerts = relationship("CrisisAlert", back_populates="user")
# wellness_scores = relationship("WellnessScore", back_populates="user")
# lifestyle_logs = relationship("LifestyleLog", back_populates="user")
# wellness_goals = relationship("WellnessGoal", back_populates="user")
# daily_checkins = relationship("DailyCheckin", back_populates="user")
# goal_selections = relationship("UserGoalSelection", back_populates="user", uselist=False)
