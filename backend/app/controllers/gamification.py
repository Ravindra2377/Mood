from fastapi import APIRouter, HTTPException, Depends
from app.schemas.gamification import (
    AchievementRead,
    AchievementCreate,
    StreakRead,
    RewardRead,
    RewardCreate,
    ClaimedRewardRead,
)
from app.dependencies import get_current_user

router = APIRouter()


@router.get('/achievements', response_model=list[AchievementRead])
def list_achievements(current_user = Depends(get_current_user)):
    from app.main import SessionLocal
    from app.models.gamification import Achievement, PointsLedger
    db = SessionLocal()
    try:
        items = db.query(Achievement).filter(Achievement.user_id == current_user.id).all()
        return items
    finally:
        db.close()


@router.post('/achievements', response_model=AchievementRead)
def create_achievement(payload: AchievementCreate, current_user = Depends(get_current_user)):
    """Create or increment an achievement for the current user.

    If an achievement with the same key exists for the user, increment its points
    and return the existing record. Otherwise create a new one.
    """
    from app.main import SessionLocal
    from app.models.gamification import Achievement, PointsLedger
    db = SessionLocal()
    try:
        existing = db.query(Achievement).filter(
            Achievement.user_id == current_user.id,
            Achievement.key == payload.key,
        ).first()
        if existing:
            # increment points if provided and record ledger
            if payload.points:
                existing.points = (existing.points or 0) + payload.points
                ledger = PointsLedger(user_id=current_user.id, change=payload.points, reason=f'achievement:{payload.key}')
                db.add(ledger)
                # mark profile active
                from app.models.profile import Profile
                p = db.query(Profile).filter(Profile.user_id == current_user.id).first()
                if p:
                    p.engagement_status = 'active'
                    db.add(p)
            db.add(existing)
            db.commit()
            db.refresh(existing)
            return existing

        a = Achievement(user_id=current_user.id, key=payload.key, points=payload.points or 0)
        db.add(a)
        if payload.points:
            ledger = PointsLedger(user_id=current_user.id, change=payload.points, reason=f'achievement:{payload.key}')
            db.add(ledger)
            from app.models.profile import Profile
            p = db.query(Profile).filter(Profile.user_id == current_user.id).first()
            if p:
                p.engagement_status = 'active'
                db.add(p)
        db.commit()
        db.refresh(a)
        return a
    finally:
        db.close()




@router.post('/streaks/record', response_model=dict)
def record_activity(date: str | None = None, current_user = Depends(get_current_user)):
    """Record activity for streaks. If activity happened today (or provided date), increment streaks.

    Simple rule: if last_active_at is yesterday or earlier than 24 hours, increment current_streak; if more than 48 hours gap, reset to 1.
    Returns current and best streak counts.
    """
    from app.main import SessionLocal
    from app.models.gamification import Streak
    from datetime import datetime, timezone, timedelta
    from app.models.profile import Profile
    db = SessionLocal()
    try:
        s = db.query(Streak).filter(Streak.user_id == current_user.id).first()
        now = datetime.now(timezone.utc)
        if not s:
            s = Streak(user_id=current_user.id, current_streak=1, best_streak=1, last_active_at=now)
            db.add(s)
            # mark profile as active
            p = db.query(Profile).filter(Profile.user_id == current_user.id).first()
            if p:
                p.engagement_status = 'active'
                db.add(p)
            db.commit()
            db.refresh(s)
            return {"current_streak": s.current_streak, "best_streak": s.best_streak}

        last = s.last_active_at
        if not last:
            s.current_streak = 1
        else:
            delta = now - last
            if delta <= timedelta(hours=48):
                # treat as continuing streak
                s.current_streak = (s.current_streak or 0) + 1
            else:
                s.current_streak = 1

        if (s.best_streak or 0) < s.current_streak:
            s.best_streak = s.current_streak

        s.last_active_at = now
        # mark profile active
        p = db.query(Profile).filter(Profile.user_id == current_user.id).first()
        if p:
            p.engagement_status = 'active'
            db.add(p)
        db.add(s)
        db.commit()
        db.refresh(s)
        return {"current_streak": s.current_streak, "best_streak": s.best_streak}
    finally:
        db.close()



@router.get('/streaks', response_model=StreakRead)
def get_streak(current_user = Depends(get_current_user)):
    from app.main import SessionLocal
    from app.models.gamification import Streak
    db = SessionLocal()
    try:
        s = db.query(Streak).filter(Streak.user_id == current_user.id).first()
        if not s:
            raise HTTPException(status_code=404, detail='No streak found')
        return s
    finally:
        db.close()



@router.get('/rewards', response_model=list[RewardRead])
def list_rewards():
    from app.main import SessionLocal
    from app.models.gamification import Reward
    db = SessionLocal()
    try:
        return db.query(Reward).all()
    finally:
        db.close()


@router.post('/rewards', response_model=RewardRead)
def create_reward(payload: RewardCreate, current_user = Depends(get_current_user)):
    """Create a reward. For now any authenticated user can create; in production restrict to admins."""
    from app.main import SessionLocal
    from app.models.gamification import Reward
    db = SessionLocal()
    try:
        # conditionally require admin role based on config flag
        from app.config import settings
        if settings.REQUIRE_ADMIN_FOR_REWARDS and getattr(current_user, 'role', 'user') != 'admin':
            raise HTTPException(status_code=403, detail='Admin role required')

        existing = db.query(Reward).filter(Reward.key == payload.key).first()
        if existing:
            raise HTTPException(status_code=400, detail='Reward key already exists')
        r = Reward(key=payload.key, title=payload.title, description=payload.description, cost_points=payload.cost_points)
        db.add(r)
        db.commit()
        db.refresh(r)
        return r
    finally:
        db.close()


@router.post('/rewards/{reward_key}/claim', response_model=ClaimedRewardRead)
def claim_reward(reward_key: str, metadata: dict | None = None, current_user = Depends(get_current_user)):
    from app.main import SessionLocal
    from app.models.gamification import Reward, ClaimedReward, Achievement, PointsLedger
    import json
    db = SessionLocal()
    try:
        r = db.query(Reward).filter(Reward.key == reward_key).first()
        if not r:
            raise HTTPException(status_code=404, detail='Reward not found')

        # Check user points via ledger sum
        from sqlalchemy import func
        total = db.query(PointsLedger).filter(PointsLedger.user_id == current_user.id).with_entities(func.coalesce(func.sum(PointsLedger.change), 0)).scalar() or 0

        if total < r.cost_points:
            raise HTTPException(status_code=400, detail='Not enough points')

        # perform atomic deduction: insert ledger entry with negative change and create claimed reward in one transaction
        try:
            # deduct
            deduction = PointsLedger(user_id=current_user.id, change=-r.cost_points, reason=f'claim:{r.key}')
            db.add(deduction)
            cr = ClaimedReward(user_id=current_user.id, reward_id=r.id, meta=json.dumps(metadata) if metadata else None)
            db.add(cr)
            db.commit()
            db.refresh(cr)
            return cr
        except Exception:
            db.rollback()
            raise HTTPException(status_code=500, detail='Failed to claim reward')
    finally:
        db.close()



@router.get('/points', response_model=dict)
def get_points(current_user = Depends(get_current_user)):
    from app.main import SessionLocal
    from app.models.gamification import PointsLedger
    from sqlalchemy import func
    db = SessionLocal()
    try:
        total = db.query(PointsLedger).filter(PointsLedger.user_id == current_user.id).with_entities(func.coalesce(func.sum(PointsLedger.change), 0)).scalar() or 0
        return {'points': int(total)}
    finally:
        db.close()


@router.get('/claimed', response_model=list[ClaimedRewardRead])
def list_claimed(current_user = Depends(get_current_user)):
    from app.main import SessionLocal
    from app.models.gamification import ClaimedReward
    db = SessionLocal()
    try:
        items = db.query(ClaimedReward).filter(ClaimedReward.user_id == current_user.id).all()
        return items
    finally:
        db.close()


@router.post('/claimed/{claim_id}/refund', response_model=ClaimedRewardRead)
def refund_claim(claim_id: int, current_user = Depends(get_current_user)):
    """Refund a claimed reward: mark as refunded and add points back to user's ledger. Admin or owner may refund."""
    from app.main import SessionLocal
    from app.models.gamification import ClaimedReward, PointsLedger, Reward
    from sqlalchemy import func
    db = SessionLocal()
    try:
        cr = db.query(ClaimedReward).filter(ClaimedReward.id == claim_id).first()
        if not cr:
            raise HTTPException(status_code=404, detail='Claim not found')
        # allow owner or admin
        if cr.user_id != current_user.id and getattr(current_user, 'role', 'user') != 'admin':
            raise HTTPException(status_code=403, detail='Not authorized')

        if cr.refunded:
            raise HTTPException(status_code=400, detail='Already refunded')

        reward = db.query(Reward).filter(Reward.id == cr.reward_id).first()
        if not reward:
            raise HTTPException(status_code=400, detail='Reward not found')

        # perform refund transaction
        try:
            # add ledger positive change
            refund_entry = PointsLedger(user_id=cr.user_id, change=reward.cost_points, reason=f'refund:{reward.key}')
            db.add(refund_entry)
            cr.refunded = 1
            from datetime import datetime, timezone
            cr.refunded_at = datetime.now(timezone.utc)
            db.add(cr)
            db.commit()
            db.refresh(cr)
            return cr
        except Exception:
            db.rollback()
            raise HTTPException(status_code=500, detail='Refund failed')
    finally:
        db.close()


@router.get('/engagement/summary', response_model=dict)
def engagement_summary(current_user = Depends(get_current_user)):
    """Return aggregated engagement metrics for the current user."""
    from app.main import SessionLocal
    from app.models.gamification import PointsLedger, Achievement, Streak
    from sqlalchemy import func
    db = SessionLocal()
    try:
        uid = current_user.id
        points = db.query(func.coalesce(func.sum(PointsLedger.change), 0)).filter(PointsLedger.user_id == uid).scalar() or 0
        streak = db.query(Streak).filter(Streak.user_id == uid).first()
        achievements_count = db.query(func.count(Achievement.id)).filter(Achievement.user_id == uid).scalar() or 0

        # determine last activity
        last_dates = []
        if streak and streak.last_active_at:
            last_dates.append(streak.last_active_at)
        ach_max = db.query(func.max(Achievement.created_at)).filter(Achievement.user_id == uid).scalar()
        if ach_max:
            last_dates.append(ach_max)
        ledger_max = db.query(func.max(PointsLedger.created_at)).filter(PointsLedger.user_id == uid).scalar()
        if ledger_max:
            last_dates.append(ledger_max)

        last_activity = max(last_dates) if last_dates else None

        return {
            'points': int(points),
            'current_streak': int(streak.current_streak) if streak else 0,
            'achievements': int(achievements_count),
            'last_activity': last_activity.isoformat() if last_activity else None,
        }
    finally:
        db.close()
