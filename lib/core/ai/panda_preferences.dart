import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_colors.dart';

/// Defines the vibe or persona the panda companion should embody.
enum PandaPersona {
  playfulBuddy,
  gentleGuide,
  mindfulMentor,
}

extension PandaPersonaDisplay on PandaPersona {
  String get label {
    switch (this) {
      case PandaPersona.playfulBuddy:
        return 'Playful Buddy';
      case PandaPersona.gentleGuide:
        return 'Gentle Guide';
      case PandaPersona.mindfulMentor:
        return 'Mindful Mentor';
    }
  }

  String get description {
    switch (this) {
      case PandaPersona.playfulBuddy:
        return 'Bubbly encouragement, energetic pep talks, and confetti vibes.';
      case PandaPersona.gentleGuide:
        return 'Soft reassurance, grounding reminders, and calm breathing cues.';
      case PandaPersona.mindfulMentor:
        return 'Focused planning, mindful nudges, and progress celebrates.';
    }
  }

  Color get accentColor {
    switch (this) {
      case PandaPersona.playfulBuddy:
        return AppColors.happyPastel;
      case PandaPersona.gentleGuide:
        return AppColors.calmPastel;
      case PandaPersona.mindfulMentor:
        return AppColors.coolPastel;
    }
  }

  String decorateMessage(String message, String displayName) {
    final name = displayName.isEmpty ? 'Mochi' : displayName;
    switch (this) {
      case PandaPersona.playfulBuddy:
        return '$name wants to party: $message';
      case PandaPersona.gentleGuide:
        return "$name whispers gently: $message";
      case PandaPersona.mindfulMentor:
        return '$name strategizes with you: $message';
    }
  }
}

/// Shared preference wrapper that keeps panda name and vibe consistent across screens.
class PandaPreferences extends ChangeNotifier {
  PandaPreferences._(this._prefs, this._name, this._persona);

  static const _nameKey = 'panda_name';
  static const _personaKey = 'panda_persona';

  final SharedPreferences _prefs;
  String _name;
  PandaPersona _persona;

  static PandaPreferences? _cached;

  static Future<PandaPreferences> instance() async {
    final existing = _cached;
    if (existing != null) return existing;

    final prefs = await SharedPreferences.getInstance();
    final storedName = prefs.getString(_nameKey) ?? 'Mochi';
    final personaIndex = prefs.getInt(_personaKey);

    PandaPersona persona = PandaPersona.playfulBuddy;
    if (personaIndex != null &&
        personaIndex >= 0 &&
        personaIndex < PandaPersona.values.length) {
      persona = PandaPersona.values[personaIndex];
    }

    final instance = PandaPreferences._(prefs, storedName, persona);
    _cached = instance;
    return instance;
  }

  String get name => _name;

  PandaPersona get persona => _persona;

  String get displayName => _name.isEmpty ? 'Mochi' : _name;

  Future<void> updateName(String value) async {
    final trimmed = value.trim();
    if (trimmed == _name) return;
    _name = trimmed;
    await _prefs.setString(_nameKey, _name);
    notifyListeners();
  }

  Future<void> updatePersona(PandaPersona value) async {
    if (value == _persona) return;
    _persona = value;
    await _prefs.setInt(_personaKey, value.index);
    notifyListeners();
  }
}
