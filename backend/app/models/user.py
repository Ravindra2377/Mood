from datetime import datetime, timezone

from sqlalchemy import Boolean, Column, DateTime, Integer, String
from sqlalchemy.orm import relationship

from app.models import Base


class User(Base):
	__tablename__ = 'users'

	id = Column(Integer, primary_key=True, index=True)
	email = Column(String, unique=True, index=True, nullable=False)
	hashed_password = Column(String, nullable=False)
	is_active = Column(Boolean, default=True)
	is_verified = Column(Boolean, default=False)
	role = Column(String, default='user', nullable=False)
	last_login = Column(DateTime(timezone=True), nullable=True)
	password_reset_token = Column(String, nullable=True)
	password_reset_expires = Column(DateTime(timezone=True), nullable=True)
	created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))

	stress_logs = relationship(
		"StressLog", back_populates="user", cascade="all, delete-orphan"
	)
	stress_exercises = relationship(
		"StressExercise", back_populates="user", cascade="all, delete-orphan"
	)
	stress_journal_entries = relationship(
		"StressJournalEntry", back_populates="user", cascade="all, delete-orphan"
	)
	mood_activities = relationship(
		"MoodActivity", back_populates="user", cascade="all, delete-orphan"
	)
	mood_correlations = relationship(
		"MoodCorrelation", back_populates="user", cascade="all, delete-orphan"
	)
	gratitude_entries = relationship(
		"GratitudeEntry", back_populates="user", cascade="all, delete-orphan"
	)
	sleep_logs = relationship(
		"SleepLog", back_populates="user", cascade="all, delete-orphan"
	)
	sleep_factors = relationship(
		"SleepFactor", back_populates="user", cascade="all, delete-orphan"
	)
	sleep_meditations = relationship(
		"SleepMeditation", back_populates="user", cascade="all, delete-orphan"
	)
	meditation_sessions = relationship(
		"MeditationSession", back_populates="user", cascade="all, delete-orphan"
	)
	mindfulness_achievements = relationship(
		"MindfulnessAchievement", back_populates="user", cascade="all, delete-orphan"
	)
	anxiety_logs = relationship(
		"AnxietyLog", back_populates="user", cascade="all, delete-orphan"
	)
	anxiety_coping_techniques = relationship(
		"AnxietyCopingTechnique", back_populates="user", cascade="all, delete-orphan"
	)
	safety_plan = relationship(
		"SafetyPlan", back_populates="user", cascade="all, delete-orphan", uselist=False
	)
	crisis_alerts = relationship(
		"CrisisAlert", back_populates="user", cascade="all, delete-orphan"
	)
	wellness_scores = relationship(
		"WellnessScore", back_populates="user", cascade="all, delete-orphan"
	)
	lifestyle_logs = relationship(
		"LifestyleLog", back_populates="user", cascade="all, delete-orphan"
	)
	wellness_goals = relationship(
		"WellnessGoal", back_populates="user", cascade="all, delete-orphan"
	)
	daily_checkins = relationship(
		"DailyCheckin", back_populates="user", cascade="all, delete-orphan"
	)
	goal_selections = relationship(
		"UserGoalSelection", back_populates="user", cascade="all, delete-orphan", uselist=False
	)
