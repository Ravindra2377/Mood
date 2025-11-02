import 'dart:math';

import 'panda_preferences.dart';

/// Describes the emotional context the panda companion can embody.
enum PandaMood {
  welcome,
  happy,
  calm,
  anxious,
  sad,
  lonely,
  celebrate,
  focus,
}

/// Simple AI layer that selects empathetic responses for the panda companion.
class PandaAI {
  PandaAI({Random? random}) : _random = random ?? Random();

  final Random _random;

  final Map<PandaMood, List<String>> _responses = {
    PandaMood.welcome: [
      "Hey there! 👋 Ready to check in?",
      "Hi friend! I saved your favorite breathing exercise.",
      "Welcome back! Want to share how you're feeling today?",
    ],
    PandaMood.happy: [
      "Your happiness makes me smile too! 🎉",
      "What a lovely glow! Let's celebrate that joy together.",
      "I'm so proud of you for finding bright moments today!",
    ],
    PandaMood.calm: [
      "Deep breaths in, deep breaths out. I'm right here with you 💚",
      "Let's stay grounded together. Try a gentle stretch?",
      "Your calm energy is contagious. Keep flowing like this breeze.",
    ],
    PandaMood.anxious: [
      "I'm here. Let's breathe in for four, out for four 💨",
      "You are safe with me. We can take this one small step at a time.",
      "Would you like a quick grounding exercise? I'm ready when you are.",
    ],
    PandaMood.sad: [
      "It's okay to feel this way. Your feelings are valid 💙",
      "Lean on me for a moment. Want to jot a gentle reflection?",
      "I'm wrapping you in the softest hug. We can rest together.",
    ],
    PandaMood.lonely: [
      "You're never alone. I'm always here for you 🐼💚",
      "How about we journal together for a few minutes?",
      "Let's reach out to someone you trust—I'll help you compose a message.",
    ],
    PandaMood.celebrate: [
      "WOW! You're unstoppable! 🏆",
      "Seven-day streak unlocked! Let's do a happy dance!",
      "Confetti mode activated! Keep shining so brightly!",
    ],
    PandaMood.focus: [
      "Shall we plan your next small win?",
      "I've sorted today's top priorities—ready to dive in?",
      "Mindful focus mode on. I'll cheer for each step you take!",
    ],
  };

  /// Returns a supportive message for the requested [mood].
  String messageFor(PandaMood mood) {
    final options = _responses[mood];
    if (options == null || options.isEmpty) {
      return "I'm here whenever you need me.";
    }
    return options[_random.nextInt(options.length)];
  }

  /// Returns a message tailored to the current [persona] and companion [name].
  String personalizedMessage(
    PandaMood mood, {
    required PandaPersona persona,
    required String name,
  }) {
    final base = messageFor(mood);
    return persona.decorateMessage(base, name);
  }
}
