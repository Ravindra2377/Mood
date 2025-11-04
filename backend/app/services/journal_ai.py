"""Utility helpers for running lightweight NLP analyses on journal content."""
from __future__ import annotations

import asyncio
import logging
import re
from collections import Counter
from functools import lru_cache
from typing import List

from pydantic import BaseModel, Field

try:
    from transformers import pipeline  # type: ignore
except Exception:  # pragma: no cover - import guard for optional dependency
    pipeline = None  # type: ignore

logger = logging.getLogger(__name__)

_SENTIMENT_MODEL = "distilbert-base-uncased-finetuned-sst-2-english"
_KEYWORD_STOPWORDS = {
    "a",
    "an",
    "and",
    "are",
    "at",
    "be",
    "but",
    "for",
    "from",
    "had",
    "have",
    "has",
    "i",
    "in",
    "is",
    "it",
    "its",
    "of",
    "on",
    "or",
    "so",
    "that",
    "the",
    "their",
    "there",
    "they",
    "this",
    "to",
    "was",
    "were",
    "with",
    "you",
    "your",
}


class AnalysisResult(BaseModel):
    """Structured output from the journal analysis pipeline."""

    sentiment: str = "neutral"
    sentiment_score: float = 0.0
    keywords: List[str] = Field(default_factory=list)


@lru_cache(maxsize=1)
def _load_sentiment_pipeline():
    """Lazily create and cache the Hugging Face pipeline."""
    if pipeline is None:
        raise RuntimeError("transformers pipeline is not available")
    logger.info("Loading sentiment analysis pipeline: %s", _SENTIMENT_MODEL)
    return pipeline("sentiment-analysis", model=_SENTIMENT_MODEL)


def _extract_keywords(text: str, limit: int = 5) -> List[str]:
    tokens = re.findall(r"[A-Za-z'][A-Za-z']+", text.lower())
    filtered = [token for token in tokens if token not in _KEYWORD_STOPWORDS and len(token) > 2]
    if not filtered:
        return []
    counts = Counter(filtered)
    return [word for word, _ in counts.most_common(limit)]


def _run_analysis_sync(text: str) -> AnalysisResult:
    try:
        nlp = _load_sentiment_pipeline()
        result = nlp(text, truncation=True)[0]
        sentiment = result.get("label", "neutral").lower()
        score = float(result.get("score", 0.0))
        keywords = _extract_keywords(text)
        return AnalysisResult(sentiment=sentiment, sentiment_score=score, keywords=keywords)
    except Exception as exc:  # pragma: no cover - resilience path
        logger.exception("Journal analysis failed: %s", exc)
        return AnalysisResult(sentiment="unknown", sentiment_score=0.0, keywords=[])


async def analyze_journal_text(text: str) -> AnalysisResult:
    """Run sentiment + keyword extraction on the provided journal body."""

    stripped = text.strip()
    if not stripped:
        return AnalysisResult()

    # transformers pipeline is CPU-bound; offload to default executor to avoid blocking event loop
    return await asyncio.to_thread(_run_analysis_sync, stripped)