from datetime import datetime, timezone, timedelta
from typing import List
from app.models.personalization import EngagementEvent, Recommendation
from app.models.user import User
from sqlalchemy.orm import Session


def record_event(db: Session, user: User, event_type: str, metadata: dict | None = None) -> EngagementEvent:
    ev = EngagementEvent(user_id=user.id, event_type=event_type, meta=metadata)
    db.add(ev)
    db.commit()
    db.refresh(ev)
    return ev


def generate_recommendations(db: Session, user: User, lookback_minutes: int = 1440) -> List[Recommendation]:
    since = datetime.now(timezone.utc) - timedelta(minutes=lookback_minutes)
    events = db.query(EngagementEvent).filter(EngagementEvent.user_id == user.id, EngagementEvent.created_at >= since).all()
    # very simple rules: if user submitted many journal entries, suggest CBT content; if low mood events, suggest grounding
    score_map = {}
    for e in events:
        t = e.event_type
        if t == 'journal.create':
            score_map['content_cbt_intro'] = score_map.get('content_cbt_intro', 0) + 3
        elif t == 'mood.low':
            score_map['content_grounding_breath'] = score_map.get('content_grounding_breath', 0) + 5
        elif t == 'mood.happy':
            score_map['content_gratitude_exercise'] = score_map.get('content_gratitude_exercise', 0) + 2
        else:
            score_map['content_general_checkin'] = score_map.get('content_general_checkin', 0) + 1

    recs = []
    for k, v in sorted(score_map.items(), key=lambda x: -x[1]):
        r = Recommendation(user_id=user.id, content_key=k, score=v)
        db.add(r)
        db.commit()
        db.refresh(r)
        recs.append(r)
    return recs
