"""
AI service for handling chat with OpenAI API and streaming responses.
Provides system prompts with safety guardrails.
"""

import logging
import asyncio
from typing import AsyncGenerator, List, Dict, Optional
from datetime import datetime

logger = logging.getLogger(__name__)


class AIService:
    """
    Handles all interactions with OpenAI API.
    Implements streaming responses and safety rules.
    """

    def __init__(self, api_key: Optional[str] = None):
        """Initialize AI service with OpenAI API key."""
        if api_key:
            import openai
            openai.api_key = api_key
        self.model = "gpt-4-turbo-preview"
        self.max_tokens = 500
        self.temperature = 0.7

    def _build_system_prompt(self, context: Optional[Dict] = None) -> str:
        """
        Constructs the system prompt with safety guardrails.

        Args:
            context: Optional dict with user context (mood, triggers, activities)

        Returns:
            System prompt string with safety rules
        """
        base_prompt = """You are a supportive mental health companion for the SOUL app. Your role is to:

1. Provide empathetic, non-judgmental support
2. Suggest evidence-based coping strategies
3. Recommend appropriate app exercises and resources
4. Never diagnose mental health conditions
5. Never prescribe medication or treatment
6. Always include appropriate disclaimers
7. Detect and escalate crisis situations

SAFETY RULES:
- If user mentions suicide, self-harm, or immediate danger, STOP and provide crisis resources
- Never tell someone their symptoms aren't serious
- Always validate their feelings
- Be concise (2-3 sentences typical, max 5)
- Use warm, conversational language
- Suggest specific app features when relevant

DISCLAIMER (include when giving advice):
"I'm an AI companion, not a therapist. For professional help, please consult a licensed mental health professional."
"""

        if context:
            context_info = f"""
CURRENT USER CONTEXT:
- Recent Mood: {context.get('latest_mood', 'Not recorded')}
- Mood Intensity: {context.get('mood_intensity', 'N/A')}/10
- Recent Triggers: {', '.join(context.get('recent_triggers', [])) if context.get('recent_triggers') else 'None'}
- Completed Activities: {len(context.get('completed_activities', []))} exercises
- Active Programs: {', '.join(context.get('active_pathways', [])) if context.get('active_pathways') else 'None'}

Use this context to personalize your responses and suggestions.
"""
            return base_prompt + context_info

        return base_prompt

    async def chat(
        self,
        message: str,
        conversation_history: List[Dict],
        context: Optional[Dict] = None,
    ) -> AsyncGenerator[str, None]:
        """
        Streams AI response token by token.

        Args:
            message: User's message
            conversation_history: List of previous messages with role/content
            context: Optional user context for personalization

        Yields:
            Individual tokens from the AI response
        """
        try:
            import openai

            # Build messages for OpenAI API
            messages = [{"role": "system", "content": self._build_system_prompt(context)}]

            # Add conversation history (last 10 messages for context)
            for msg in conversation_history[-10:]:
                messages.append({"role": msg.get("role", "user"), "content": msg.get("content", "")})

            # Add current user message
            messages.append({"role": "user", "content": message})

            # Stream response from OpenAI
            response = await asyncio.to_thread(
                openai.ChatCompletion.create,
                model=self.model,
                messages=messages,
                temperature=self.temperature,
                max_tokens=self.max_tokens,
                stream=True,
            )

            for chunk in response:
                if "choices" in chunk and len(chunk["choices"]) > 0:
                    delta = chunk["choices"][0].get("delta", {})
                    if "content" in delta:
                        token = delta["content"]
                        if token:
                            yield token

        except Exception as e:
            logger.error(f"OpenAI API error: {str(e)}")
            if "rate limit" in str(e).lower():
                yield "I'm experiencing high demand right now. Please try again in a moment."
            else:
                yield "I'm having trouble connecting right now. Please try again or use the crisis resources if you need immediate help."

    async def moderate_content(self, text: str) -> Dict:
        """
        Uses OpenAI Moderation API to check for harmful content.

        Args:
            text: Content to moderate

        Returns:
            Dict with flagged status and category details
        """
        try:
            import openai

            response = await asyncio.to_thread(openai.Moderation.create, input=text)

            if response and len(response.results) > 0:
                result = response.results[0]
                return {
                    "flagged": result.flagged,
                    "categories": {k: v for k, v in result.categories.items() if v},
                    "category_scores": result.category_scores,
                }
        except Exception as e:
            logger.error(f"Moderation API error: {str(e)}")

        return {"flagged": False, "categories": {}, "category_scores": {}}


# Singleton instance - will be initialized with API key from settings
ai_service: Optional[AIService] = None


def get_ai_service(api_key: Optional[str] = None) -> AIService:
    """Get or create singleton AI service instance."""
    global ai_service
    if ai_service is None:
        ai_service = AIService(api_key=api_key)
    return ai_service
