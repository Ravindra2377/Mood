"""
Mental Health Tracking Services - Business logic layer
Handles all data processing, analytics, and recommendations
"""

from sqlalchemy.orm import Session
from sqlalchemy import and_, func, desc
from datetime import datetime, timezone, timedelta
from typing import List, Dict, Optional, Any
import statistics
from app.models.mental_health_tracking import (
    StressLog, StressExercise, StressJournalEntry,
    MoodActivity, MoodCorrelation, GratitudeEntry,
    SleepLog, SleepFactor, SleepMeditation,
    MeditationSession, MeditationAchievement, MeditationContent,
    AnxietyLog, AnxietyCopingTechnique, SafetyPlan, CrisisAlert,
    WellnessScore, LifestyleLog, WellnessGoal, DailyCheckin,
    UserGoalSelection
)
from app.models.user import User
from app.schemas.mental_health_tracking import (
    StressLogCreate, StressExerciseCreate, StressJournalEntryCreate,
    MoodActivityCreate, GratitudeEntryCreate,
    SleepLogCreate, SleepFactorCreate, SleepMeditationCreate,
    MeditationSessionCreate, MeditationContentCreate,
    AnxietyLogCreate, AnxietyCopingTechniqueCreate, SafetyPlanCreate,
    LifestyleLogCreate, WellnessGoalCreate, DailyCheckinCreate,
    UserGoalSelectionCreate
)


# ===========================
# STRESS MANAGEMENT SERVICE
# ===========================

class StressManagementService:
    """Service for stress tracking and management."""
    
    @staticmethod
    def log_stress(db: Session, user_id: int, stress_data: StressLogCreate) -> StressLog:
        """Log a stress entry."""
        stress_log = StressLog(
            user_id=user_id,
            level=stress_data.level,
            triggers=stress_data.triggers,
            notes=stress_data.notes
        )
        db.add(stress_log)
        db.commit()
        db.refresh(stress_log)
        return stress_log
    
    @staticmethod
    def log_stress_exercise(db: Session, user_id: int, exercise_data: StressExerciseCreate) -> StressExercise:
        """Log a completed stress exercise."""
        exercise = StressExercise(
            user_id=user_id,
            exercise_type=exercise_data.exercise_type.value,
            exercise_name=exercise_data.exercise_name,
            duration_seconds=exercise_data.duration_seconds,
            effectiveness_rating=exercise_data.effectiveness_rating,
            notes=exercise_data.notes
        )
        db.add(exercise)
        db.commit()
        db.refresh(exercise)
        return exercise
    
    @staticmethod
    def create_stress_journal_entry(db: Session, user_id: int, entry_data: StressJournalEntryCreate) -> StressJournalEntry:
        """Create a stress journal entry."""
        entry = StressJournalEntry(
            user_id=user_id,
            title=entry_data.title,
            content=entry_data.content,
            stress_level_before=entry_data.stress_level_before,
            stress_level_after=entry_data.stress_level_after,
            triggers=entry_data.triggers,
            coping_strategies_used=entry_data.coping_strategies_used
        )
        db.add(entry)
        db.commit()
        db.refresh(entry)
        return entry
    
    @staticmethod
    def get_stress_trends(db: Session, user_id: int, days: int = 30) -> Dict[str, Any]:
        """Get stress trends for the given period."""
        cutoff_date = datetime.now(timezone.utc) - timedelta(days=days)
        
        logs = db.query(StressLog).filter(
            and_(
                StressLog.user_id == user_id,
                StressLog.timestamp >= cutoff_date
            )
        ).all()
        
        if not logs:
            return {}
        
        levels = [log.level for log in logs]
        all_triggers = {}
        
        for log in logs:
            for trigger in log.triggers:
                all_triggers[trigger] = all_triggers.get(trigger, 0) + 1
        
        # Get most effective exercises
        exercises = db.query(StressExercise).filter(
            and_(
                StressExercise.user_id == user_id,
                StressExercise.completed_at >= cutoff_date,
                StressExercise.effectiveness_rating.isnot(None)
            )
        ).all()
        
        top_exercises = {}
        for ex in exercises:
            key = ex.exercise_name
            if key not in top_exercises:
                top_exercises[key] = []
            top_exercises[key].append(ex.effectiveness_rating)
        
        top_exercises_sorted = [
            {
                "name": name,
                "avg_effectiveness": statistics.mean(ratings),
                "times_used": len(ratings)
            }
            for name, ratings in top_exercises.items()
        ]
        top_exercises_sorted.sort(key=lambda x: x["avg_effectiveness"], reverse=True)
        
        return {
            "average_level": statistics.mean(levels),
            "trend": StressManagementService._calculate_trend(levels),
            "most_common_triggers": sorted(all_triggers.items(), key=lambda x: x[1], reverse=True)[:5],
            "most_effective_exercises": top_exercises_sorted[:5],
            "period": f"{days} days",
            "data_points": len(logs)
        }
    
    @staticmethod
    def _calculate_trend(values: List[int]) -> str:
        """Calculate trend from values: increasing, decreasing, or stable."""
        if len(values) < 3:
            return "stable"
        
        first_half = statistics.mean(values[:len(values)//2])
        second_half = statistics.mean(values[len(values)//2:])
        
        diff_percent = ((second_half - first_half) / first_half) * 100 if first_half != 0 else 0
        
        if diff_percent > 10:
            return "increasing"
        elif diff_percent < -10:
            return "decreasing"
        else:
            return "stable"


# ===========================
# MOOD TRACKING SERVICE
# ===========================

class MoodTrackingService:
    """Service for mood tracking and improvements."""
    
    @staticmethod
    def log_mood_activity(db: Session, user_id: int, activity_data: MoodActivityCreate) -> MoodActivity:
        """Log a mood-boosting activity."""
        activity = MoodActivity(
            user_id=user_id,
            activity_type=activity_data.activity_type.value,
            activity_name=activity_data.activity_name,
            mood_before=activity_data.mood_before,
            mood_after=activity_data.mood_after,
            duration_minutes=activity_data.duration_minutes,
            effectiveness_rating=activity_data.effectiveness_rating,
            notes=activity_data.notes
        )
        db.add(activity)
        db.commit()
        db.refresh(activity)
        
        # Update mood correlations if mood data is available
        if activity_data.mood_before and activity_data.mood_after:
            MoodTrackingService._update_activity_correlation(db, user_id, activity_data.activity_type.value)
        
        return activity
    
    @staticmethod
    def create_gratitude_entry(db: Session, user_id: int, entry_data: GratitudeEntryCreate) -> GratitudeEntry:
        """Create a gratitude journal entry."""
        entry = GratitudeEntry(
            user_id=user_id,
            content=entry_data.content,
            mood_before=entry_data.mood_before,
            category=entry_data.category
        )
        db.add(entry)
        db.commit()
        db.refresh(entry)
        return entry
    
    @staticmethod
    def _update_activity_correlation(db: Session, user_id: int, activity_type: str):
        """Update mood correlation for an activity type."""
        activities = db.query(MoodActivity).filter(
            and_(
                MoodActivity.user_id == user_id,
                MoodActivity.activity_type == activity_type,
                MoodActivity.mood_before.isnot(None),
                MoodActivity.mood_after.isnot(None)
            )
        ).all()
        
        if activities:
            mood_improvements = [
                (a.mood_after - a.mood_before) for a in activities
            ]
            correlation_score = statistics.mean(mood_improvements) / 10.0  # Normalize to -1 to 1
            
            correlation = db.query(MoodCorrelation).filter(
                and_(
                    MoodCorrelation.user_id == user_id,
                    MoodCorrelation.factor_type == "activity",
                    MoodCorrelation.factor_value == activity_type
                )
            ).first()
            
            if correlation:
                correlation.correlation_score = correlation_score
                correlation.data_points = len(activities)
                correlation.last_updated = datetime.now(timezone.utc)
            else:
                correlation = MoodCorrelation(
                    user_id=user_id,
                    factor_type="activity",
                    factor_value=activity_type,
                    correlation_score=correlation_score,
                    data_points=len(activities)
                )
                db.add(correlation)
            
            db.commit()
    
    @staticmethod
    def get_mood_insights(db: Session, user_id: int, days: int = 30) -> Dict[str, Any]:
        """Get mood insights and trends."""
        cutoff_date = datetime.now(timezone.utc) - timedelta(days=days)
        
        activities = db.query(MoodActivity).filter(
            and_(
                MoodActivity.user_id == user_id,
                MoodActivity.mood_after.isnot(None),
                MoodActivity.completed_at >= cutoff_date
            )
        ).all()
        
        if not activities:
            return {}
        
        moods_after = [a.mood_after for a in activities]
        
        # Get top activities by effectiveness
        top_activities = {}
        for activity in activities:
            if activity.effectiveness_rating:
                key = activity.activity_name
                if key not in top_activities:
                    top_activities[key] = []
                top_activities[key].append(activity.effectiveness_rating)
        
        top_activities_sorted = [
            {
                "activity": name,
                "avg_effectiveness": statistics.mean(ratings),
                "times_used": len(ratings)
            }
            for name, ratings in top_activities.items()
        ]
        top_activities_sorted.sort(key=lambda x: x["avg_effectiveness"], reverse=True)
        
        # Get correlations
        correlations = db.query(MoodCorrelation).filter(
            MoodCorrelation.user_id == user_id
        ).all()
        
        return {
            "average_mood": statistics.mean(moods_after),
            "mood_trend": StressManagementService._calculate_trend(moods_after),
            "top_activities": top_activities_sorted[:5],
            "correlations": [
                {
                    "factor_type": c.factor_type,
                    "factor_value": c.factor_value,
                    "correlation_score": c.correlation_score,
                    "data_points": c.data_points
                }
                for c in correlations
            ],
            "recent_entries": len(activities),
            "period": f"{days} days"
        }


# ===========================
# SLEEP TRACKING SERVICE
# ===========================

class SleepTrackingService:
    """Service for sleep tracking and optimization."""
    
    @staticmethod
    def log_sleep(db: Session, user_id: int, sleep_data: SleepLogCreate) -> SleepLog:
        """Log a sleep session."""
        duration = (sleep_data.wake_time - sleep_data.bedtime).total_seconds() / 3600
        
        sleep_log = SleepLog(
            user_id=user_id,
            bedtime=sleep_data.bedtime,
            wake_time=sleep_data.wake_time,
            duration_hours=duration,
            quality_rating=sleep_data.quality_rating,
            notes=sleep_data.notes
        )
        db.add(sleep_log)
        db.commit()
        db.refresh(sleep_log)
        return sleep_log
    
    @staticmethod
    def log_sleep_factors(db: Session, user_id: int, factors_data: SleepFactorCreate) -> SleepFactor:
        """Log factors affecting sleep."""
        factors = SleepFactor(
            user_id=user_id,
            date=factors_data.date,
            caffeine_intake=factors_data.caffeine_intake,
            alcohol_intake=factors_data.alcohol_intake,
            exercise_minutes=factors_data.exercise_minutes,
            screen_time_minutes=factors_data.screen_time_minutes,
            stress_level=factors_data.stress_level,
            notes=factors_data.notes
        )
        db.add(factors)
        db.commit()
        db.refresh(factors)
        return factors
    
    @staticmethod
    def get_sleep_trends(db: Session, user_id: int, days: int = 30) -> Dict[str, Any]:
        """Get sleep trends and recommendations."""
        cutoff_date = datetime.now(timezone.utc) - timedelta(days=days)
        
        sleep_logs = db.query(SleepLog).filter(
            and_(
                SleepLog.user_id == user_id,
                SleepLog.created_at >= cutoff_date
            )
        ).all()
        
        if not sleep_logs:
            return {}
        
        durations = [log.duration_hours for log in sleep_logs]
        qualities = [log.quality_rating for log in sleep_logs if log.quality_rating]
        
        # Calculate sleep debt (recommended 7-9 hours per night)
        recommended_hours = 8
        total_debt = sum(max(0, recommended_hours - duration) for duration in durations)
        
        # Get factors affecting sleep
        factors = db.query(SleepFactor).filter(
            and_(
                SleepFactor.user_id == user_id,
                SleepFactor.date >= cutoff_date
            )
        ).all()
        
        factors_analysis = SleepTrackingService._analyze_sleep_factors(db, user_id, factors)
        
        return {
            "average_duration": statistics.mean(durations),
            "average_quality": statistics.mean(qualities) if qualities else None,
            "trend": StressManagementService._calculate_trend([int(d) for d in durations]),
            "factors_affecting_sleep": factors_analysis,
            "sleep_debt_hours": total_debt,
            "optimal_duration_recommendation": 8.0,
            "period": f"{days} days"
        }
    
    @staticmethod
    def _analyze_sleep_factors(db: Session, user_id: int, factors: List[SleepFactor]) -> List[Dict]:
        """Analyze which factors most affect sleep quality."""
        if not factors:
            return []
        
        sleep_logs = db.query(SleepLog).filter(
            SleepLog.user_id == user_id
        ).all()
        
        analysis = []
        # Analyze caffeine effect
        high_caffeine = [f for f in factors if f.caffeine_intake and f.caffeine_intake > 200]
        if high_caffeine:
            analysis.append({
                "factor": "High caffeine intake",
                "impact": "negative",
                "frequency": len(high_caffeine)
            })
        
        # Analyze screen time
        high_screen = [f for f in factors if f.screen_time_minutes and f.screen_time_minutes > 60]
        if high_screen:
            analysis.append({
                "factor": "High screen time before bed",
                "impact": "negative",
                "frequency": len(high_screen)
            })
        
        # Analyze exercise
        exercise_logs = [f for f in factors if f.exercise_minutes and f.exercise_minutes > 30]
        if exercise_logs:
            analysis.append({
                "factor": "Regular exercise",
                "impact": "positive",
                "frequency": len(exercise_logs)
            })
        
        return analysis


# ===========================
# MINDFULNESS SERVICE
# ===========================

class MindfulnessService:
    """Service for mindfulness and meditation tracking."""
    
    @staticmethod
    def log_meditation(db: Session, user_id: int, session_data: MeditationSessionCreate) -> MeditationSession:
        """Log a meditation session."""
        session = MeditationSession(
            user_id=user_id,
            meditation_type=session_data.meditation_type.value,
            meditation_id=session_data.meditation_id,
            title=session_data.title,
            duration_seconds=session_data.duration_seconds,
            mood_before=session_data.mood_before,
            focus_level=session_data.focus_level,
            notes=session_data.notes
        )
        db.add(session)
        db.commit()
        db.refresh(session)
        
        # Check for achievements
        MindfulnessService._check_achievements(db, user_id)
        
        return session
    
    @staticmethod
    def _check_achievements(db: Session, user_id: int):
        """Check if user has unlocked any achievements."""
        sessions = db.query(MeditationSession).filter(
            MeditationSession.user_id == user_id
        ).all()
        
        total_sessions = len(sessions)
        
        # 7-day streak
        if total_sessions >= 7:
            existing = db.query(MindfulnessAchievement).filter(
                and_(
                    MindfulnessAchievement.user_id == user_id,
                    MindfulnessAchievement.achievement_type == "streak_7"
                )
            ).first()
            
            if not existing:
                achievement = MindfulnessAchievement(
                    user_id=user_id,
                    achievement_type="streak_7",
                    achievement_name="First Week",
                    description="Complete 7 meditation sessions"
                )
                db.add(achievement)
        
        # 30-day streak
        if total_sessions >= 30:
            existing = db.query(MindfulnessAchievement).filter(
                and_(
                    MindfulnessAchievement.user_id == user_id,
                    MindfulnessAchievement.achievement_type == "streak_30"
                )
            ).first()
            
            if not existing:
                achievement = MindfulnessAchievement(
                    user_id=user_id,
                    achievement_type="streak_30",
                    achievement_name="Meditation Master",
                    description="Complete 30 meditation sessions"
                )
                db.add(achievement)
        
        db.commit()
    
    @staticmethod
    def get_mindfulness_stats(db: Session, user_id: int) -> Dict[str, Any]:
        """Get comprehensive mindfulness statistics."""
        sessions = db.query(MeditationSession).filter(
            MeditationSession.user_id == user_id
        ).order_by(MeditationSession.completed_at.desc()).all()
        
        if not sessions:
            return {}
        
        total_minutes = sum(s.duration_seconds for s in sessions) / 60
        
        # Calculate streak
        current_streak = MindfulnessService._calculate_streak(sessions)
        longest_streak = MindfulnessService._calculate_longest_streak(sessions)
        
        # Most practiced type
        type_counts = {}
        for session in sessions:
            type_counts[session.meditation_type] = type_counts.get(session.meditation_type, 0) + 1
        
        most_practiced = max(type_counts.items(), key=lambda x: x[1])[0] if type_counts else None
        
        # Mood improvement
        mood_improvements = [
            (s.mood_after - s.mood_before) 
            for s in sessions 
            if s.mood_after and s.mood_before
        ]
        
        avg_mood_improvement = statistics.mean(mood_improvements) if mood_improvements else None
        
        return {
            "total_sessions": len(sessions),
            "total_minutes_meditated": total_minutes,
            "current_streak": current_streak,
            "longest_streak": longest_streak,
            "average_session_duration": statistics.mean([s.duration_seconds/60 for s in sessions]),
            "most_practiced_type": most_practiced,
            "last_session": sessions[0].completed_at if sessions else None,
            "mood_improvement": avg_mood_improvement
        }
    
    @staticmethod
    def _calculate_streak(sessions: List[MeditationSession]) -> int:
        """Calculate current meditation streak."""
        if not sessions:
            return 0
        
        streak = 1
        today = datetime.now(timezone.utc).date()
        last_date = sessions[0].completed_at.date()
        
        if (today - last_date).days > 1:
            return 0
        
        for i in range(1, len(sessions)):
            current_date = sessions[i].completed_at.date()
            if (last_date - current_date).days == 1:
                streak += 1
                last_date = current_date
            else:
                break
        
        return streak
    
    @staticmethod
    def _calculate_longest_streak(sessions: List[MeditationSession]) -> int:
        """Calculate longest meditation streak."""
        if not sessions:
            return 0
        
        longest = 1
        current = 1
        
        sorted_sessions = sorted(sessions, key=lambda s: s.completed_at)
        
        for i in range(1, len(sorted_sessions)):
            prev_date = sorted_sessions[i-1].completed_at.date()
            curr_date = sorted_sessions[i].completed_at.date()
            
            if (curr_date - prev_date).days == 1:
                current += 1
                longest = max(longest, current)
            elif curr_date != prev_date:
                current = 1
        
        return longest


# ===========================
# ANXIETY MANAGEMENT SERVICE
# ===========================

class AnxietyManagementService:
    """Service for anxiety tracking and coping."""
    
    @staticmethod
    def log_anxiety(db: Session, user_id: int, anxiety_data: AnxietyLogCreate) -> AnxietyLog:
        """Log an anxiety episode."""
        anxiety_log = AnxietyLog(
            user_id=user_id,
            level=anxiety_data.level,
            triggers=anxiety_data.triggers,
            symptoms=anxiety_data.symptoms,
            duration_minutes=anxiety_data.duration_minutes,
            intensity=anxiety_data.intensity.value,
            is_panic_attack=anxiety_data.is_panic_attack,
            notes=anxiety_data.notes
        )
        db.add(anxiety_log)
        db.commit()
        db.refresh(anxiety_log)
        
        # Check for crisis
        if anxiety_data.level >= 8 or anxiety_data.is_panic_attack:
            AnxietyManagementService._create_crisis_alert(db, user_id, anxiety_log)
        
        return anxiety_log
    
    @staticmethod
    def log_coping_technique(db: Session, user_id: int, technique_data: AnxietyCopingTechniqueCreate) -> AnxietyCopingTechnique:
        """Log a coping technique used."""
        technique = AnxietyCopingTechnique(
            user_id=user_id,
            technique_name=technique_data.technique_name,
            technique_type=technique_data.technique_type,
            description=technique_data.description,
            duration_minutes=technique_data.duration_minutes,
            effectiveness_rating=technique_data.effectiveness_rating,
            anxiety_level_before=technique_data.anxiety_level_before,
            anxiety_level_after=technique_data.anxiety_level_after
        )
        db.add(technique)
        db.commit()
        db.refresh(technique)
        return technique
    
    @staticmethod
    def _create_crisis_alert(db: Session, user_id: int, anxiety_log: AnxietyLog):
        """Create a crisis alert if needed."""
        alert_level = "critical" if anxiety_log.is_panic_attack else "high"
        
        alert = CrisisAlert(
            user_id=user_id,
            alert_level=alert_level,
            trigger_reason="Anxiety episode" if not anxiety_log.is_panic_attack else "Panic attack detected",
            description=anxiety_log.notes
        )
        db.add(alert)
        db.commit()
    
    @staticmethod
    def update_safety_plan(db: Session, user_id: int, plan_data: SafetyPlanCreate) -> SafetyPlan:
        """Update or create user's safety plan."""
        plan = db.query(SafetyPlan).filter(
            SafetyPlan.user_id == user_id
        ).first()
        
        if not plan:
            plan = SafetyPlan(user_id=user_id)
        
        plan.warning_signs = plan_data.warning_signs
        plan.internal_coping = plan_data.internal_coping
        plan.people_to_contact = plan_data.people_to_contact
        plan.professional_contacts = plan_data.professional_contacts
        plan.crisis_hotlines = plan_data.crisis_hotlines
        plan.ways_to_make_environment_safer = plan_data.ways_to_make_environment_safer
        plan.plan_content = plan_data.plan_content
        plan.updated_at = datetime.now(timezone.utc)
        
        db.add(plan)
        db.commit()
        db.refresh(plan)
        return plan


# ===========================
# WELLNESS SERVICE
# ===========================

class WellnessService:
    """Service for overall wellness tracking."""
    
    @staticmethod
    def create_daily_checkin(db: Session, user_id: int, checkin_data: DailyCheckinCreate) -> DailyCheckin:
        """Create a daily wellness check-in."""
        checkin = DailyCheckin(
            user_id=user_id,
            date=checkin_data.date,
            mood=checkin_data.mood,
            energy=checkin_data.energy,
            stress=checkin_data.stress,
            sleep_quality=checkin_data.sleep_quality,
            overall_wellness=checkin_data.overall_wellness,
            notes=checkin_data.notes
        )
        db.add(checkin)
        db.commit()
        db.refresh(checkin)
        
        # Update wellness score
        WellnessService._calculate_and_store_wellness_score(db, user_id)
        
        return checkin
    
    @staticmethod
    def _calculate_and_store_wellness_score(db: Session, user_id: int):
        """Calculate and store overall wellness score."""
        today = datetime.now(timezone.utc).date()
        
        # Get latest data from all categories
        stress_logs = db.query(StressLog).filter(
            and_(
                StressLog.user_id == user_id,
                func.date(StressLog.timestamp) == today
            )
        ).all()
        
        anxiety_logs = db.query(AnxietyLog).filter(
            and_(
                AnxietyLog.user_id == user_id,
                func.date(AnxietyLog.created_at) == today
            )
        ).all()
        
        sleep_logs = db.query(SleepLog).filter(
            and_(
                SleepLog.user_id == user_id,
                func.date(SleepLog.created_at) == today
            )
        ).all()
        
        meditation_sessions = db.query(MeditationSession).filter(
            and_(
                MeditationSession.user_id == user_id,
                func.date(MeditationSession.completed_at) == today
            )
        ).all()
        
        lifestyle_logs = db.query(LifestyleLog).filter(
            and_(
                LifestyleLog.user_id == user_id,
                func.date(LifestyleLog.logged_at) == today
            )
        ).all()
        
        # Calculate component scores (0-100)
        stress_score = 100 - (statistics.mean([s.level for s in stress_logs]) * 10 if stress_logs else 50)
        anxiety_score = 100 - (statistics.mean([a.level for a in anxiety_logs]) * 10 if anxiety_logs else 50)
        meditation_score = min(100, (len(meditation_sessions) * 20) + 50) if meditation_sessions else 50
        sleep_score = min(100, (len(sleep_logs) * 50) + 50) if sleep_logs else 50
        
        # Overall score (average of components)
        overall_score = statistics.mean([stress_score, anxiety_score, meditation_score, sleep_score])
        
        # Store score
        score = WellnessScore(
            user_id=user_id,
            date=datetime.now(timezone.utc),
            overall_score=overall_score,
            stress_score=stress_score,
            anxiety_score=anxiety_score,
            sleep_score=sleep_score,
            exercise_score=50,  # Placeholder
            social_score=50,  # Placeholder
            nutrition_score=50  # Placeholder
        )
        db.add(score)
        db.commit()
    
    @staticmethod
    def log_lifestyle_activity(db: Session, user_id: int, activity_data: LifestyleLogCreate) -> LifestyleLog:
        """Log a lifestyle activity."""
        activity = LifestyleLog(
            user_id=user_id,
            activity_type=activity_data.activity_type,
            activity_name=activity_data.activity_name,
            value=activity_data.value,
            unit=activity_data.unit,
            intensity=activity_data.intensity,
            notes=activity_data.notes
        )
        db.add(activity)
        db.commit()
        db.refresh(activity)
        return activity
    
    @staticmethod
    def create_wellness_goal(db: Session, user_id: int, goal_data: WellnessGoalCreate) -> WellnessGoal:
        """Create a wellness goal."""
        goal = WellnessGoal(
            user_id=user_id,
            goal_type=goal_data.goal_type,
            goal_name=goal_data.goal_name,
            target_value=goal_data.target_value,
            unit=goal_data.unit,
            timeframe=goal_data.timeframe,
            deadline=goal_data.deadline
        )
        db.add(goal)
        db.commit()
        db.refresh(goal)
        return goal
    
    @staticmethod
    def save_goal_selection(db: Session, user_id: int, selection_data: UserGoalSelectionCreate) -> UserGoalSelection:
        """Save user's selected goal categories."""
        selection = db.query(UserGoalSelection).filter(
            UserGoalSelection.user_id == user_id
        ).first()
        
        if not selection:
            selection = UserGoalSelection(user_id=user_id)
        
        selection.goal_categories = [cat.value for cat in selection_data.goal_categories]
        selection.customization_preferences = selection_data.customization_preferences
        selection.updated_at = datetime.now(timezone.utc)
        
        db.add(selection)
        db.commit()
        db.refresh(selection)
        return selection
