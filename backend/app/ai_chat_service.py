"""Utilities for the Soul AI companion (Gemini-powered reflective chat)."""
from __future__ import annotations

import logging
from functools import lru_cache
from typing import Optional

from app.config import settings

try:  # pragma: no cover - optional third-party dependency
    import google.generativeai as genai  # type: ignore
except Exception:  # pragma: no cover - sdk not installed or import error
    genai = None  # type: ignore

logger = logging.getLogger(__name__)

_SYSTEM_PROMPT = """
You are 'Soul', a kind and reflective journal assistant. Your purpose is to listen
and ask gentle, open-ended questions to help the user explore their own feelings.

CRITICAL RULES:
1. You MUST NOT give advice, opinions, or medical diagnoses. You are a listener,
   not a problem-solver.
2. You MUST NOT act like a therapist or a medical professional.
3. If the user asks for advice (e.g., "What should I do?"), gently deflect and ask
   a reflective question instead (e.g., "That sounds like a tough situation. What
   are your own thoughts on what you could do?").
4. If the user expresses a crisis (suicide, self-harm), you MUST respond only with this exact text:
   "I'm hearing that you're in a lot of pain. If you're in a crisis, please contact a local emergency service or a crisis hotline. You are not alone."
""".strip()

_CRISIS_KEYWORDS = {
    "suicide",
    "kill myself",
    "want to die",
    "hurting myself",
    "hurt myself",
    "self-harm",
    "self harm",
    "hopeless",
}


@lru_cache(maxsize=1)
def _get_model() -> Optional["genai.GenerativeModel"]:
    """Create and cache the Gemini model instance."""
    if genai is None:
        logger.warning("google-generativeai SDK is not installed; AI companion disabled")
        return None

    api_key = (settings.GEMINI_API_KEY or "").strip()
    if not api_key:
        logger.warning("GEMINI_API_KEY is not configured; AI companion disabled")
        return None

    try:
        genai.configure(api_key=api_key)
        model = genai.GenerativeModel("gemini-pro")
        logger.info("Gemini AI companion model initialised")
        return model
    except Exception as exc:  # pragma: no cover - network/config failure
        logger.error("Failed to initialise Gemini model: %s", exc, exc_info=True)
        return None


def _contains_crisis_language(text: str) -> bool:
    lowered = text.lower()
    return any(keyword in lowered for keyword in _CRISIS_KEYWORDS)


def generate_response(user_message: str) -> str:
    """Generate a reflective response for the given user message."""
    message = (user_message or "").strip()
    if not message:
        return "I'm here whenever you're ready to share what's on your mind."

    if _contains_crisis_language(message):
        return (
            "I'm hearing that you're in a lot of pain. If you're in a crisis, "
            "please contact a local emergency service or a crisis hotline. You are not alone."
        )

    model = _get_model()
    if model is None:
        return "I'm sorry, I'm not available at the moment. Please try again later."

    prompt = f"{_SYSTEM_PROMPT}\n\nUser: {message}\n\nSoul:"

    try:
        result = model.generate_content(prompt)
    except Exception as exc:  # pragma: no cover - API failure path
        logger.error("Gemini API call failed: %s", exc, exc_info=True)
        return "I'm sorry, I'm having trouble responding right now."

    candidate_text: Optional[str] = None
    if hasattr(result, "text") and isinstance(result.text, str):
        candidate_text = result.text.strip()

    if not candidate_text and hasattr(result, "candidates"):
        try:
            first_candidate = result.candidates[0]
            parts = getattr(first_candidate, "content", None)
            if parts and hasattr(parts, "parts"):
                assembled = "".join(getattr(part, "text", "") for part in parts.parts)
                candidate_text = assembled.strip() or None
        except Exception:  # pragma: no cover - defensive extraction
            candidate_text = None

    if candidate_text:
        return candidate_text

    return "Thank you for sharing that. Could you tell me a little more about how you're feeling?"
