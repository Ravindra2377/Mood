import 'package:flutter/material.dart';

class Exercise {
  final String id;
  final String name;
  final String category;
  final Duration duration;
  final String description;
  final List<String> benefits;
  final IconData icon;
  final Color color;

  Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.duration,
    required this.description,
    required this.benefits,
    required this.icon,
    required this.color,
  });
}

class ExerciseSession {
  final String exerciseId;
  final DateTime startTime;
  DateTime? endTime;
  int? moodBefore;
  int? moodAfter;
  String? notes;
  Map<String, dynamic>? extraData;

  ExerciseSession({
    required this.exerciseId,
    required this.startTime,
    this.endTime,
    this.moodBefore,
    this.moodAfter,
    this.notes,
    this.extraData,
  });

  Duration get duration =>
      endTime != null ? endTime!.difference(startTime) : Duration.zero;

  Map<String, dynamic> toJson() => {
        'exercise_id': exerciseId,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime?.toIso8601String(),
        'mood_before': moodBefore,
        'mood_after': moodAfter,
        'notes': notes,
        'duration_seconds': duration.inSeconds,
        'extra_data': extraData,
      };
}

// Breathing exercise patterns
enum BreathingPhase { inhale, hold, exhale, holdTwo }

class BreathingPattern {
  final String name;
  final List<int> phaseDurations; // seconds for each phase
  final List<BreathingPhase> phases;

  BreathingPattern({
    required this.name,
    required this.phaseDurations,
    required this.phases,
  });

  static BreathingPattern boxBreathing = BreathingPattern(
    name: 'Box Breathing',
    phaseDurations: [4, 4, 4, 4],
    phases: [
      BreathingPhase.inhale,
      BreathingPhase.hold,
      BreathingPhase.exhale,
      BreathingPhase.holdTwo,
    ],
  );

  static BreathingPattern fourSevenEight = BreathingPattern(
    name: '4-7-8 Breathing',
    phaseDurations: [4, 7, 8],
    phases: [
      BreathingPhase.inhale,
      BreathingPhase.hold,
      BreathingPhase.exhale,
    ],
  );

  static BreathingPattern resonant = BreathingPattern(
    name: 'Resonant Breathing',
    phaseDurations: [5, 5],
    phases: [
      BreathingPhase.inhale,
      BreathingPhase.exhale,
    ],
  );
}
