def contains_crisis_language(text: str) -> bool:
    lowered = text.lower()
    triggers = ['suicide', 'kill myself', 'hurt myself', 'end my life']
    return any(t in lowered for t in triggers)
