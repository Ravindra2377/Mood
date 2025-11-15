from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from typing import List
from app.database import get_db
from app.models.exercise import (
    Exercise, ExerciseSession, ExerciseStreak, FavoriteExercise,
    ExerciseCategoryEnum, ExerciseDifficultyEnum
)
from app.schemas.exercise import (
    ExerciseCreate, ExerciseRead, ExerciseUpdate, ExerciseStats,
    ExerciseSessionCreate, ExerciseSessionComplete, ExerciseSessionRead,
    ExerciseSessionDetail, UserExerciseStats, UserExerciseProgress,
    ExerciseStrengthArea, FavoriteExerciseCreate, ExerciseListResponse,
    ExerciseSessionListResponse
)
from app.auth import get_current_user

router = APIRouter(prefix="/api/exercises", tags=["exercises"])


# ===== EXERCISE ENDPOINTS =====

@router.get("/", response_model=ExerciseListResponse)
async def get_exercises(
    category: str = Query(None),
    difficulty: str = Query(None),
    page: int = Query(1, ge=1),
    per_page: int = Query(10, ge=1, le=100),
    db: Session = Depends(get_db),
):
    """Get all exercises with filtering and pagination"""
    query = db.query(Exercise).filter(Exercise.is_active == True)
    
    if category:
        query = query.filter(Exercise.category == category)
    if difficulty:
        query = query.filter(Exercise.difficulty == difficulty)
    
    total = query.count()
    exercises = query.offset((page - 1) * per_page).limit(per_page).all()
    
    return ExerciseListResponse(
        items=[ExerciseRead.from_orm(e) for e in exercises],
        total=total,
        page=page,
        per_page=per_page,
        pages=(total + per_page - 1) // per_page
    )


@router.get("/categories")
async def get_exercise_categories():
    """Get all exercise categories"""
    return {
        "categories": [e.value for e in ExerciseCategoryEnum]
    }


@router.get("/difficulties")
async def get_exercise_difficulties():
    """Get all exercise difficulty levels"""
    return {
        "difficulties": [d.value for d in ExerciseDifficultyEnum]
    }


@router.get("/{exercise_id}", response_model=ExerciseRead)
async def get_exercise(
    exercise_id: int,
    db: Session = Depends(get_db),
):
    """Get single exercise by ID"""
    exercise = db.query(Exercise).filter(
        Exercise.id == exercise_id,
        Exercise.is_active == True
    ).first()
    
    if not exercise:
        raise HTTPException(status_code=404, detail="Exercise not found")
    
    return ExerciseRead.from_orm(exercise)


@router.post("/", response_model=ExerciseRead)
async def create_exercise(
    exercise: ExerciseCreate,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
):
    """Create new exercise (admin only)"""
    # Check if user is admin - add admin check here
    
    db_exercise = Exercise(**exercise.dict())
    db.add(db_exercise)
    db.commit()
    db.refresh(db_exercise)
    
    return ExerciseRead.from_orm(db_exercise)


@router.put("/{exercise_id}", response_model=ExerciseRead)
async def update_exercise(
    exercise_id: int,
    exercise: ExerciseUpdate,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
):
    """Update exercise (admin only)"""
    db_exercise = db.query(Exercise).filter(Exercise.id == exercise_id).first()
    
    if not db_exercise:
        raise HTTPException(status_code=404, detail="Exercise not found")
    
    for key, value in exercise.dict(exclude_unset=True).items():
        setattr(db_exercise, key, value)
    
    db_exercise.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(db_exercise)
    
    return ExerciseRead.from_orm(db_exercise)


@router.get("/{exercise_id}/stats", response_model=ExerciseStats)
async def get_exercise_stats(
    exercise_id: int,
    db: Session = Depends(get_db),
):
    """Get statistics for an exercise"""
    exercise = db.query(Exercise).filter(Exercise.id == exercise_id).first()
    
    if not exercise:
        raise HTTPException(status_code=404, detail="Exercise not found")
    
    # Calculate average mood improvement
    sessions = db.query(ExerciseSession).filter(
        ExerciseSession.exercise_id == exercise_id,
        ExerciseSession.completed == True,
        ExerciseSession.mood_after != None
    ).all()
    
    avg_improvement = 0.0
    if sessions:
        improvements = [s.mood_after - s.mood_before for s in sessions]
        avg_improvement = sum(improvements) / len(improvements)
    
    # Count favorites
    favorite_count = db.query(FavoriteExercise).filter(
        FavoriteExercise.exercise_id == exercise_id
    ).count()
    
    return ExerciseStats(
        exercise_id=exercise.id,
        exercise_name=exercise.name,
        total_completions=exercise.total_completions,
        average_rating=exercise.average_rating,
        total_reviews=exercise.total_reviews,
        average_mood_improvement=avg_improvement,
        average_duration=0.0,  # Calculate from sessions
        favorite_count=favorite_count
    )


# ===== EXERCISE SESSION ENDPOINTS =====

@router.post("/session/start", response_model=ExerciseSessionRead)
async def start_exercise_session(
    session_data: ExerciseSessionCreate,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
):
    """Start an exercise session"""
    exercise = db.query(Exercise).filter(Exercise.id == session_data.exercise_id).first()
    
    if not exercise:
        raise HTTPException(status_code=404, detail="Exercise not found")
    
    db_session = ExerciseSession(
        user_id=current_user.id,
        exercise_id=session_data.exercise_id,
        mood_before=session_data.mood_before,
        energy_before=session_data.energy_before,
        stress_before=session_data.stress_before,
    )
    db.add(db_session)
    db.commit()
    db.refresh(db_session)
    
    return ExerciseSessionRead.from_orm(db_session)


@router.post("/session/{session_id}/complete", response_model=ExerciseSessionRead)
async def complete_exercise_session(
    session_id: int,
    completion_data: ExerciseSessionComplete,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
):
    """Complete an exercise session"""
    db_session = db.query(ExerciseSession).filter(
        ExerciseSession.id == session_id,
        ExerciseSession.user_id == current_user.id
    ).first()
    
    if not db_session:
        raise HTTPException(status_code=404, detail="Session not found")
    
    if db_session.completed:
        raise HTTPException(status_code=400, detail="Session already completed")
    
    db_session.completed_at = datetime.utcnow()
    db_session.duration_seconds = completion_data.duration_seconds
    db_session.mood_after = completion_data.mood_after
    db_session.energy_after = completion_data.energy_after
    db_session.stress_after = completion_data.stress_after
    db_session.rating = completion_data.rating
    db_session.review = completion_data.review
    db_session.notes = completion_data.notes
    db_session.completed = True
    
    # Update exercise statistics
    exercise = db.query(Exercise).filter(Exercise.id == db_session.exercise_id).first()
    exercise.total_completions += 1
    
    if completion_data.rating:
        exercise.average_rating = (
            (exercise.average_rating * exercise.total_reviews + completion_data.rating) /
            (exercise.total_reviews + 1)
        )
        exercise.total_reviews += 1
    
    # Update user streak
    streak = db.query(ExerciseStreak).filter(
        ExerciseStreak.user_id == current_user.id
    ).first()
    
    if not streak:
        streak = ExerciseStreak(user_id=current_user.id)
        db.add(streak)
    
    today = datetime.utcnow().date()
    last_session_date = streak.last_session_date.date() if streak.last_session_date else None
    
    if last_session_date == today:
        # Already exercised today
        pass
    elif last_session_date == today - timedelta(days=1):
        # Streak continues
        streak.current_streak += 1
    else:
        # Streak broken
        streak.current_streak = 1
    
    if streak.current_streak > streak.longest_streak:
        streak.longest_streak = streak.current_streak
    
    streak.last_session_date = datetime.utcnow()
    streak.total_exercises_completed += 1
    streak.total_time_minutes += completion_data.duration_seconds // 60
    
    db.commit()
    db.refresh(db_session)
    
    return ExerciseSessionRead.from_orm(db_session)


@router.get("/sessions/my-sessions", response_model=ExerciseSessionListResponse)
async def get_my_sessions(
    page: int = Query(1, ge=1),
    per_page: int = Query(10, ge=1, le=100),
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
):
    """Get current user's exercise sessions"""
    query = db.query(ExerciseSession).filter(ExerciseSession.user_id == current_user.id)
    
    total = query.count()
    sessions = query.order_by(ExerciseSession.created_at.desc()).offset(
        (page - 1) * per_page
    ).limit(per_page).all()
    
    return ExerciseSessionListResponse(
        items=[ExerciseSessionRead.from_orm(s) for s in sessions],
        total=total,
        page=page,
        per_page=per_page,
        pages=(total + per_page - 1) // per_page
    )


@router.get("/sessions/{session_id}", response_model=ExerciseSessionDetail)
async def get_session_detail(
    session_id: int,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
):
    """Get detailed exercise session"""
    db_session = db.query(ExerciseSession).filter(
        ExerciseSession.id == session_id,
        ExerciseSession.user_id == current_user.id
    ).first()
    
    if not db_session:
        raise HTTPException(status_code=404, detail="Session not found")
    
    return ExerciseSessionDetail.from_orm(db_session)


# ===== USER STATS ENDPOINTS =====

@router.get("/user/stats", response_model=UserExerciseStats)
async def get_user_exercise_stats(
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
):
    """Get user's exercise statistics"""
    streak = db.query(ExerciseStreak).filter(
        ExerciseStreak.user_id == current_user.id
    ).first()
    
    if not streak:
        return UserExerciseStats(
            total_exercises_completed=0,
            total_time_minutes=0,
            current_streak=0,
            longest_streak=0,
            average_mood_improvement=0.0,
            average_rating=0.0,
            favorite_exercises_count=0,
            exercises_this_week=0,
            exercises_this_month=0,
        )
    
    # Exercises this week
    week_ago = datetime.utcnow() - timedelta(days=7)
    exercises_week = db.query(ExerciseSession).filter(
        ExerciseSession.user_id == current_user.id,
        ExerciseSession.completed == True,
        ExerciseSession.completed_at >= week_ago
    ).count()
    
    # Exercises this month
    month_ago = datetime.utcnow() - timedelta(days=30)
    exercises_month = db.query(ExerciseSession).filter(
        ExerciseSession.user_id == current_user.id,
        ExerciseSession.completed == True,
        ExerciseSession.completed_at >= month_ago
    ).count()
    
    # Average mood improvement
    sessions = db.query(ExerciseSession).filter(
        ExerciseSession.user_id == current_user.id,
        ExerciseSession.completed == True,
        ExerciseSession.mood_after != None
    ).all()
    
    avg_improvement = 0.0
    if sessions:
        improvements = [s.mood_after - s.mood_before for s in sessions]
        avg_improvement = sum(improvements) / len(improvements)
    
    # Average rating
    rated_sessions = [s for s in sessions if s.rating]
    avg_rating = 0.0
    if rated_sessions:
        avg_rating = sum(s.rating for s in rated_sessions) / len(rated_sessions)
    
    # Favorite exercises
    favorites = db.query(FavoriteExercise).filter(
        FavoriteExercise.user_id == current_user.id
    ).count()
    
    return UserExerciseStats(
        total_exercises_completed=streak.total_exercises_completed,
        total_time_minutes=streak.total_time_minutes,
        current_streak=streak.current_streak,
        longest_streak=streak.longest_streak,
        average_mood_improvement=round(avg_improvement, 2),
        average_rating=round(avg_rating, 2),
        favorite_exercises_count=favorites,
        exercises_this_week=exercises_week,
        exercises_this_month=exercises_month,
    )


@router.get("/user/progress", response_model=UserExerciseProgress)
async def get_user_progress(
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
):
    """Get user's exercise progress and recommendations"""
    stats = await get_user_exercise_stats(db=db, current_user=current_user)
    
    # Calculate strength areas (categories with most completions)
    sessions = db.query(ExerciseSession).filter(
        ExerciseSession.user_id == current_user.id,
        ExerciseSession.completed == True
    ).all()
    
    category_stats = {}
    for session in sessions:
        exercise = db.query(Exercise).filter(Exercise.id == session.exercise_id).first()
        if exercise:
            cat = exercise.category.value
            if cat not in category_stats:
                category_stats[cat] = {
                    "completions": 0,
                    "ratings": [],
                }
            category_stats[cat]["completions"] += 1
            if session.rating:
                category_stats[cat]["ratings"].append(session.rating)
    
    strength_areas = [
        ExerciseStrengthArea(
            category=cat,
            exercises_completed=data["completions"],
            average_rating=sum(data["ratings"]) / len(data["ratings"]) if data["ratings"] else 0
        )
        for cat, data in sorted(category_stats.items(), key=lambda x: x[1]["completions"], reverse=True)[:5]
    ]
    
    # Recommend exercises (popular, not yet tried by user)
    tried_exercises = [s.exercise_id for s in sessions]
    recommended = db.query(Exercise).filter(
        Exercise.is_active == True,
        ~Exercise.id.in_(tried_exercises) if tried_exercises else True
    ).order_by(Exercise.average_rating.desc(), Exercise.total_completions.desc()).limit(5).all()
    
    return UserExerciseProgress(
        stats=stats,
        strength_areas=strength_areas,
        recommended_exercises=[ExerciseRead.from_orm(e) for e in recommended]
    )


# ===== FAVORITE EXERCISE ENDPOINTS =====

@router.post("/favorites", response_model=dict)
async def add_favorite(
    favorite: FavoriteExerciseCreate,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
):
    """Add exercise to favorites"""
    exercise = db.query(Exercise).filter(Exercise.id == favorite.exercise_id).first()
    if not exercise:
        raise HTTPException(status_code=404, detail="Exercise not found")
    
    existing = db.query(FavoriteExercise).filter(
        FavoriteExercise.user_id == current_user.id,
        FavoriteExercise.exercise_id == favorite.exercise_id
    ).first()
    
    if existing:
        raise HTTPException(status_code=400, detail="Already in favorites")
    
    db_favorite = FavoriteExercise(
        user_id=current_user.id,
        exercise_id=favorite.exercise_id
    )
    db.add(db_favorite)
    db.commit()
    
    return {"message": "Added to favorites"}


@router.delete("/favorites/{exercise_id}", response_model=dict)
async def remove_favorite(
    exercise_id: int,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
):
    """Remove exercise from favorites"""
    favorite = db.query(FavoriteExercise).filter(
        FavoriteExercise.user_id == current_user.id,
        FavoriteExercise.exercise_id == exercise_id
    ).first()
    
    if not favorite:
        raise HTTPException(status_code=404, detail="Not in favorites")
    
    db.delete(favorite)
    db.commit()
    
    return {"message": "Removed from favorites"}


@router.get("/favorites", response_model=List[ExerciseRead])
async def get_favorite_exercises(
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
):
    """Get user's favorite exercises"""
    favorites = db.query(FavoriteExercise).filter(
        FavoriteExercise.user_id == current_user.id
    ).all()
    
    exercise_ids = [f.exercise_id for f in favorites]
    exercises = db.query(Exercise).filter(Exercise.id.in_(exercise_ids)).all()
    
    return [ExerciseRead.from_orm(e) for e in exercises]
