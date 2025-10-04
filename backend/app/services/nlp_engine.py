def respond_to_user(message: str, context: dict | None = None) -> str:
    """Simple NLP stub. Supports modality hints for therapeutic dialogue (cbt, dbt, mindfulness).
    This is intentionally simplistic and must be replaced by a proper, clinically-reviewed model
    before production use.
    """
    text = message.strip().lower()
    # safety checks
    if 'suicide' in text or 'hurt myself' in text or 'kill myself' in text:
        return "I'm sorry you're feeling that way. If you're in immediate danger, please contact emergency services. Would you like resources or help contacting someone now?"

    modality = None
    if context and isinstance(context, dict):
        modality = context.get('modality')
        # also allow modality passed at top-level
        if not modality:
            modality = context.get('messages', {}).get('modality') if isinstance(context.get('messages'), dict) else None

    if modality:
        modality = modality.lower()

    # CBT-style: cognitive restructuring prompt
    if modality == 'cbt':
        if 'i am worthless' in text or "i'm worthless" in text or 'i am a failure' in text:
            return "It sounds like you're having some harsh self-judgments. What evidence do you have for and against that thought? Let's try to look for balanced alternatives."
        return "Can you describe the thought that came up and what triggered it? We can try to examine the automatic thought together."

    # DBT-style: validation + problem solving
    if modality == 'dbt':
        return "I hear that this is difficult for you. It makes sense to feel upset. Would you like a grounding skill or to try a brief distress tolerance exercise?"

    # Mindfulness-style: grounding prompts
    if modality == 'mindfulness':
        return "Let's try a quick grounding exercise: notice 5 things you can see, 4 you can touch, 3 you can hear, 2 you can smell, and 1 you can taste. Tell me when you're ready."

    # generic heuristics
    if 'sad' in text or 'depressed' in text or 'down' in text:
        return "It sounds like you're going through a tough time. Would you like to try a brief grounding exercise or explore what's contributing to this feeling?"
    if 'anx' in text or 'panic' in text or 'worried' in text:
        return "I'm hearing a lot of worry—would it help to try a 4-4-4 breathing exercise or to name the thought that's most pressing right now?"

    # fallback reflection
    return "Thanks for sharing. Can you tell me a little more about that?"
