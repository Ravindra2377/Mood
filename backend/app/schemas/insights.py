from typing import Dict, List

from pydantic import BaseModel


class SentimentTimeData(BaseModel):
    """Represents a single sentiment datapoint for a given day."""

    date: str
    sentiment: str


class KeywordData(BaseModel):
    """Aggregated keyword frequency."""

    keyword: str
    count: int


class InsightsResponse(BaseModel):
    """Aggregated insights returned by the insights endpoint."""

    overall_sentiment: Dict[str, int]
    sentiment_over_time: List[SentimentTimeData]
    top_keywords: List[KeywordData]
