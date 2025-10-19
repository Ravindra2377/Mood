"""
Mental Health Tracking API Routes/Controllers
Handles all HTTP endpoints for mental health tracking features
"""

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime

from app.dependencies import get_db, get_current_user
from app.models.user import User
from app.schemas.mental_health_tracking import (
    # Stress
    StressLogCreate, StressLogResponse, StressExerciseCreate, StressExerciseResponse,
    StressJournalEntryCreate, StressJournalEntryResponse, StressTrendsResponse,
    # Mood
    MoodActivityCreate, MoodActivityResponse, GratitudeEntryCreate, GratitudeEntryResponse,
    MoodCorrelationResponse, MoodInsightsResponse,
    # Sleep
    SleepLogCreate, SleepLogResponse, SleepFactorCreate, SleepFactorResponse,
    SleepMeditationCreate, SleepMeditationResponse, SleepTrendsResponse,
    # Mindfulness
    MeditationSessionCreate, MeditationSessionResponse, MeditationContentCreate,
    MeditationContentResponse, MindfulnessStatsResponse, MindfulnessAchievementResponse,
    # Anxiety
    AnxietyLogCreate, AnxietyLogResponse, AnxietyCopingTechniqueCreate,
    AnxietyCopingTechniqueResponse, SafetyPlanCreate, SafetyPlanResponse, CrisisAlertResponse,
    # Wellness
    WellnessScoreResponse, LifestyleLogCreate, LifestyleLogResponse,
    WellnessGoalCreate, WellnessGoalResponse, DailyCheckinCreate, DailyCheckinResponse,
    UserGoalSelectionCreate, UserGoalSelectionResponse, WellnessInsightsResponse
)
from app.services.mental_health_tracking import (
    StressManagementService, MoodTrackingService, SleepTrackingService,
    MindfulnessService, AnxietyManagementService, WellnessService
)

# Create router
router = APIRouter(prefix="/api/v1/mental-health", tags=["Mental Health Tracking"])


# ===========================
# STRESS MANAGEMENT ENDPOINTS
# ===========================

@router.post("/stress/log", response_model=StressLogResponse)
def log_stress(
    stress_data: StressLogCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Log a stress level entry."""
    return StressManagementService.log_stress(db, current_user.id, stress_data)


@router.post("/stress/exercise", response_model=StressExerciseResponse)
def log_stress_exercise(
    exercise_data: StressExerciseCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Log a completed stress relief exercise."""
    return StressManagementService.log_stress_exercise(db, current_user.id, exercise_data)


@router.post("/stress/journal", response_model=StressJournalEntryResponse)
def create_stress_journal_entry(
    entry_data: StressJournalEntryCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create a stress journal entry."""
    return StressManagementService.create_stress_journal_entry(db, current_user.id, entry_data)


@router.get("/stress/trends", response_model=StressTrendsResponse)
def get_stress_trends(
    days: int = Query(30, ge=7, le=365),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get stress trends for the specified period."""
    trends = StressManagementService.get_stress_trends(db, current_user.id, days)
    if not trends:
        raise HTTPException(status_code=404, detail="No stress data found")
    return trends


# ===========================
# MOOD TRACKING ENDPOINTS
# ===========================

@router.post("/mood/activity", response_model=MoodActivityResponse)
def log_mood_activity(
    activity_data: MoodActivityCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Log a mood-boosting activity."""
    return MoodTrackingService.log_mood_activity(db, current_user.id, activity_data)


@router.post("/mood/gratitude", response_model=GratitudeEntryResponse)
def create_gratitude_entry(
    entry_data: GratitudeEntryCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create a gratitude journal entry."""
    return MoodTrackingService.create_gratitude_entry(db, current_user.id, entry_data)


@router.get("/mood/insights", response_model=MoodInsightsResponse)
def get_mood_insights(
    days: int = Query(30, ge=7, le=365),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get mood insights and trends."""
    insights = MoodTrackingService.get_mood_insights(db, current_user.id, days)
    if not insights:
        raise HTTPException(status_code=404, detail="No mood data found")
    return insights


# ===========================
# SLEEP TRACKING ENDPOINTS
# ===========================

@router.post("/sleep/log", response_model=SleepLogResponse)
def log_sleep(
    sleep_data: SleepLogCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Log a sleep session."""
    return SleepTrackingService.log_sleep(db, current_user.id, sleep_data)


@router.post("/sleep/factors", response_model=SleepFactorResponse)
def log_sleep_factors(
    factors_data: SleepFactorCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Log factors affecting sleep."""
    return SleepTrackingService.log_sleep_factors(db, current_user.id, factors_data)


@router.get("/sleep/trends", response_model=SleepTrendsResponse)
def get_sleep_trends(
    days: int = Query(30, ge=7, le=365),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get sleep trends and recommendations."""
    trends = SleepTrackingService.get_sleep_trends(db, current_user.id, days)
    if not trends:
        raise HTTPException(status_code=404, detail="No sleep data found")
    return trends


# ===========================
# MINDFULNESS ENDPOINTS
# ===========================

@router.post("/mindfulness/session", response_model=MeditationSessionResponse)
def log_meditation_session(
    session_data: MeditationSessionCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Log a meditation session."""
    return MindfulnessService.log_meditation(db, current_user.id, session_data)


@router.get("/mindfulness/stats", response_model=MindfulnessStatsResponse)
def get_mindfulness_stats(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get meditation statistics and achievements."""
    stats = MindfulnessService.get_mindfulness_stats(db, current_user.id)
    if not stats:
        raise HTTPException(status_code=404, detail="No meditation data found")
    return stats


@router.get("/mindfulness/achievements", response_model=List[MindfulnessAchievementResponse])
def get_mindfulness_achievements(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get user's unlocked mindfulness achievements."""
    from app.models.mental_health_tracking import MindfulnessAchievement
    achievements = db.query(MindfulnessAchievement).filter(
        MindfulnessAchievement.user_id == current_user.id
    ).all()
    return achievements


@router.get("/mindfulness/library", response_model=List[MeditationContentResponse])
def get_meditation_library(
    meditation_type: Optional[str] = None,
    category: Optional[str] = None,
    difficulty: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """Get meditation content library."""
    from app.models.mental_health_tracking import MeditationContent
    query = db.query(MeditationContent).filter(MeditationContent.is_active == True)
    
    if meditation_type:
        query = query.filter(MeditationContent.meditation_type == meditation_type)
    if category:
        query = query.filter(MeditationContent.category == category)
    if difficulty:
        query = query.filter(MeditationContent.difficulty_level == difficulty)
    
    return query.all()


# ===========================
# ANXIETY MANAGEMENT ENDPOINTS
# ===========================

@router.post("/anxiety/log", response_model=AnxietyLogResponse)
def log_anxiety(
    anxiety_data: AnxietyLogCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Log an anxiety episode."""
    return AnxietyManagementService.log_anxiety(db, current_user.id, anxiety_data)


@router.post("/anxiety/coping", response_model=AnxietyCopingTechniqueResponse)
def log_coping_technique(
    technique_data: AnxietyCopingTechniqueCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Log a coping technique used."""
    return AnxietyManagementService.log_coping_technique(db, current_user.id, technique_data)


@router.put("/anxiety/safety-plan", response_model=SafetyPlanResponse)
def update_safety_plan(
    plan_data: SafetyPlanCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update or create user's safety plan."""
    return AnxietyManagementService.update_safety_plan(db, current_user.id, plan_data)


@router.get("/anxiety/safety-plan", response_model=SafetyPlanResponse)
def get_safety_plan(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get user's safety plan."""
    from app.models.mental_health_tracking import SafetyPlan
    plan = db.query(SafetyPlan).filter(SafetyPlan.user_id == current_user.id).first()
    if not plan:
        raise HTTPException(status_code=404, detail="Safety plan not found")
    return plan


@router.get("/anxiety/crisis-alerts", response_model=List[CrisisAlertResponse])
def get_crisis_alerts(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get user's crisis alerts."""
    from app.models.mental_health_tracking import CrisisAlert
    alerts = db.query(CrisisAlert).filter(
        CrisisAlert.user_id == current_user.id
    ).order_by(CrisisAlert.triggered_at.desc()).all()
    return alerts


# ===========================
# WELLNESS ENDPOINTS
# ===========================

@router.post("/wellness/checkin", response_model=DailyCheckinResponse)
def create_daily_checkin(
    checkin_data: DailyCheckinCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create a daily wellness check-in."""
    return WellnessService.create_daily_checkin(db, current_user.id, checkin_data)


@router.post("/wellness/lifestyle", response_model=LifestyleLogResponse)
def log_lifestyle_activity(
    activity_data: LifestyleLogCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Log a lifestyle activity."""
    return WellnessService.log_lifestyle_activity(db, current_user.id, activity_data)


@router.post("/wellness/goal", response_model=WellnessGoalResponse)
def create_wellness_goal(
    goal_data: WellnessGoalCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create a wellness goal."""
    return WellnessService.create_wellness_goal(db, current_user.id, goal_data)


@router.get("/wellness/score", response_model=WellnessScoreResponse)
def get_latest_wellness_score(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get latest wellness score."""
    from app.models.mental_health_tracking import WellnessScore
    from sqlalchemy import desc
    score = db.query(WellnessScore).filter(
        WellnessScore.user_id == current_user.id
    ).order_by(desc(WellnessScore.date)).first()
    
    if not score:
        raise HTTPException(status_code=404, detail="Wellness score not found")
    return score


@router.get("/wellness/goals", response_model=List[WellnessGoalResponse])
def get_wellness_goals(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get user's wellness goals."""
    from app.models.mental_health_tracking import WellnessGoal
    goals = db.query(WellnessGoal).filter(
        WellnessGoal.user_id == current_user.id
    ).all()
    return goals


# ===========================
# GOAL SELECTION ENDPOINTS
# ===========================

@router.post("/goals/select", response_model=UserGoalSelectionResponse)
def select_wellness_goals(
    selection_data: UserGoalSelectionCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Select wellness goal categories."""
    return WellnessService.save_goal_selection(db, current_user.id, selection_data)


@router.get("/goals/selected", response_model=UserGoalSelectionResponse)
def get_selected_wellness_goals(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get user's selected wellness goals."""
    from app.models.mental_health_tracking import UserGoalSelection
    selection = db.query(UserGoalSelection).filter(
        UserGoalSelection.user_id == current_user.id
    ).first()
    
    if not selection:
        raise HTTPException(status_code=404, detail="Goal selection not found")
    return selection
