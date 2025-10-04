def respond_to_user(message: str, context: dict | None = None) -> str:
    # Very small stub. Replace with integration to a real AI model.
    # For now we reflect and provide a soothing prompt.
    text = message.strip().lower()
    if 'suicide' in text or 'hurt myself' in text:
        return "I'm sorry you're feeling that way. If you're in immediate danger, please contact emergency services. Would you like resources or help contacting someone now?"
    if 'sad' in text or 'depressed' in text:
        return "It sounds like you're going through a tough time. Want to try a brief grounding exercise?"
    return "Thanks for sharing. Can you tell me a little more about that?"
