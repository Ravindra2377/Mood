from collections import Counter
from datetime import datetime, timedelta, timezone
from typing import Dict, List

from sqlalchemy import Date, cast, func
from sqlalchemy.orm import Session

from app.models.journal_entry import JournalEntry
from app.schemas.insights import InsightsResponse


async def get_user_insights(user_id: int, db: Session) -> InsightsResponse:
    """Aggregate sentiment and keyword analytics for a user's journal entries."""

    # --- 1. Overall Sentiment ---
    sentiment_counts_query: List[tuple[str | None, int]] = (
        db.query(JournalEntry.sentiment, func.count(JournalEntry.id))
        .filter(
            JournalEntry.user_id == user_id,
            JournalEntry.sentiment.isnot(None),
        )
        .group_by(JournalEntry.sentiment)
        .all()
    )
    overall_sentiment: Dict[str, int] = {
        sentiment: count
        for sentiment, count in sentiment_counts_query
        if sentiment
    }

    # --- 2. Sentiment Over Time ---
    thirty_days_ago = datetime.now(timezone.utc) - timedelta(days=30)
    created_date = cast(JournalEntry.created_at, Date)
    sentiment_over_time_query: List[tuple[datetime, str | None]] = (
        db.query(created_date.label("date"), JournalEntry.sentiment)
        .filter(
            JournalEntry.user_id == user_id,
            JournalEntry.created_at >= thirty_days_ago,
            JournalEntry.sentiment.isnot(None),
        )
        .order_by(created_date.asc())
        .all()
    )
    sentiment_over_time = [
        {
            "date": date.isoformat() if hasattr(date, "isoformat") else str(date),
            "sentiment": sentiment,
        }
        for date, sentiment in sentiment_over_time_query
        if sentiment
    ]

    # --- 3. Top Keywords ---
    keyword_rows: List[tuple[str | None]] = (
        db.query(JournalEntry.keywords)
        .filter(
            JournalEntry.user_id == user_id,
            JournalEntry.keywords.isnot(None),
            JournalEntry.keywords != "",
        )
        .all()
    )

    all_keywords: List[str] = []
    for (keywords_str,) in keyword_rows:
        if not keywords_str:
            continue
        tokens = [token.strip() for token in keywords_str.split(",") if token.strip()]
        all_keywords.extend(tokens)

    top_keywords_raw = Counter(all_keywords).most_common(5)
    top_keywords = [
        {"keyword": keyword, "count": count}
        for keyword, count in top_keywords_raw
    ]

    return InsightsResponse(
        overall_sentiment=overall_sentiment,
        sentiment_over_time=sentiment_over_time,
        top_keywords=top_keywords,
    )
