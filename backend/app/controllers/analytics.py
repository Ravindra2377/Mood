from fastapi import APIRouter, Depends, HTTPException
from datetime import datetime, timedelta, timezone
from app.dependencies import require_role, get_current_user

router = APIRouter()


@router.get('/summary')
def analytics_summary(days: int = 30, current_user = Depends(require_role('admin'))):
    """Admin-only analytics summary: counts by event_type and events/day for last `days` days."""
    from app.main import SessionLocal
    db = SessionLocal()
    try:
        cutoff = datetime.now(timezone.utc) - timedelta(days=days)
        # counts by event_type
        q = db.execute("""
            SELECT event_type, COUNT(*) as cnt
            FROM analytics_events
            WHERE created_at >= :cutoff
            GROUP BY event_type
        """, {'cutoff': cutoff})
        by_type = {row['event_type']: row['cnt'] for row in q}

        # daily counts
        q2 = db.execute("""
            SELECT DATE(created_at) as day, COUNT(*) as cnt
            FROM analytics_events
            WHERE created_at >= :cutoff
            GROUP BY DATE(created_at)
            ORDER BY DATE(created_at) ASC
        """, {'cutoff': cutoff})
        daily = []
        for row in q2:
            d = row['day']
            # SQLite returns string for DATE(); ensure we return string
            daily.append({'day': d.isoformat() if hasattr(d, 'isoformat') else str(d), 'count': int(row['cnt'])})

        return {'by_type': by_type, 'daily': daily}
    finally:
        db.close()
