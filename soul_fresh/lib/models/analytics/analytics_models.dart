import 'package:uuid/uuid.dart';

int min(int a, int b) => a < b ? a : b;

// ==========================================
// EXERCISE ANALYTICS
// ==========================================

class ExerciseSession {
  final String id;
  final String exerciseId;
  final String exerciseName;
  final String category; // 'breathing', 'pmr', 'grounding', 'cognitive', 'journaling'
  final int durationMinutes;
  final DateTime completedAt;
  final int moodBefore; // 1-10
  final int moodAfter; // 1-10
  final String? notes;

  ExerciseSession({
    String? id,
    required this.exerciseId,
    required this.exerciseName,
    required this.category,
    required this.durationMinutes,
    required this.completedAt,
    required this.moodBefore,
    required this.moodAfter,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  int get moodImprovement => moodAfter - moodBefore;

  Map<String, dynamic> toJson() => {
    'id': id,
    'exerciseId': exerciseId,
    'exerciseName': exerciseName,
    'category': category,
    'duration': durationMinutes,
    'completedAt': completedAt.toIso8601String(),
    'moodBefore': moodBefore,
    'moodAfter': moodAfter,
    'notes': notes,
  };
}

class ExerciseStats {
  final List<ExerciseSession> sessions;

  ExerciseStats({required this.sessions});

  // Total sessions
  int get totalSessions => sessions.length;

  // Total time in minutes
  int get totalTimeMinutes =>
    sessions.fold(0, (sum, session) => sum + session.durationMinutes);

  // Average session duration
  double get averageSessionDuration =>
    totalSessions > 0 ? totalTimeMinutes / totalSessions : 0.0;

  // Mood improvement average
  double get averageMoodImprovement =>
    totalSessions > 0
      ? sessions.fold(0, (sum, s) => sum + s.moodImprovement) / totalSessions
      : 0.0;

  // Count by category
  Map<String, int> get sessionsByCategory {
    final counts = <String, int>{};
    for (final session in sessions) {
      counts[session.category] = (counts[session.category] ?? 0) + 1;
    }
    return counts;
  }

  // Most effective exercise
  String get mostEffectiveExercise {
    if (sessions.isEmpty) return 'None';
    final improvements = <String, List<int>>{};
    for (final session in sessions) {
      improvements
          .putIfAbsent(session.exerciseName, () => [])
          .add(session.moodImprovement);
    }

    var bestExercise = '';
    var bestAverage = -999.0;

    improvements.forEach((exercise, values) {
      final avg = values.fold(0, (sum, v) => sum + v) / values.length;
      if (avg > bestAverage) {
        bestAverage = avg;
        bestExercise = exercise;
      }
    });

    return bestExercise;
  }
}

// ==========================================
// SELF-HELP ACTIVITIES ANALYTICS
// ==========================================

class SelfHelpActivity {
  final String id;
  final String activityType; // 'thought_record', 'check_in', 'pathway', 'assessment'
  final String activityName;
  final int durationMinutes;
  final DateTime completedAt;
  final int? completionPercentage; // For guided pathways
  final String? result; // For assessments

  SelfHelpActivity({
    String? id,
    required this.activityType,
    required this.activityName,
    required this.durationMinutes,
    required this.completedAt,
    this.completionPercentage,
    this.result,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'activityType': activityType,
    'activityName': activityName,
    'duration': durationMinutes,
    'completedAt': completedAt.toIso8601String(),
    'completionPercentage': completionPercentage,
    'result': result,
  };
}

class SelfHelpStats {
  final List<SelfHelpActivity> activities;

  SelfHelpStats({required this.activities});

  // Total activities
  int get totalActivities => activities.length;

  // Total time invested
  int get totalTimeMinutes =>
    activities.fold(0, (sum, activity) => sum + activity.durationMinutes);

  // Count by activity type
  Map<String, int> get activitiesByType {
    final counts = <String, int>{};
    for (final activity in activities) {
      counts[activity.activityType] = (counts[activity.activityType] ?? 0) + 1;
    }
    return counts;
  }

  // Thought records count
  int get thoughtRecordsCount =>
    activities.where((a) => a.activityType == 'thought_record').length;

  // Check-ins count
  int get checkInsCount =>
    activities.where((a) => a.activityType == 'check_in').length;

  // Guided programs count
  int get guidedProgramsCount =>
    activities.where((a) => a.activityType == 'pathway').length;

  // Assessments count
  int get assessmentsCount =>
    activities.where((a) => a.activityType == 'assessment').length;
}

// ==========================================
// MOOD ANALYTICS
// ==========================================

class MoodEntry {
  final String id;
  final int moodScore; // 1-10
  final String? emotionalState; // 'anxious', 'sad', 'angry', 'calm', 'happy', etc.
  final List<String> triggers; // What caused this mood
  final DateTime recordedAt;

  MoodEntry({
    String? id,
    required this.moodScore,
    this.emotionalState,
    this.triggers = const [],
    required this.recordedAt,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'moodScore': moodScore,
    'emotionalState': emotionalState,
    'triggers': triggers,
    'recordedAt': recordedAt.toIso8601String(),
  };
}

class MoodStats {
  final List<MoodEntry> entries;

  MoodStats({required this.entries});

  // Average mood this week
  double get weeklyAverageMood {
    if (entries.isEmpty) return 0.0;
    return entries.fold(0, (sum, e) => sum + e.moodScore) / entries.length;
  }

  // Mood trend (comparing last 7 days)
  double get moodTrend {
    if (entries.length < 2) return 0.0;
    final sorted = List<MoodEntry>.from(entries)
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));

    if (sorted.length < 7) return 0.0;

    final lastWeek = sorted.sublist(0, 7);
    final previousWeek = sorted.sublist(7, min(14, sorted.length));

    final lastAverage = lastWeek.fold(0, (sum, e) => sum + e.moodScore) / lastWeek.length;
    final prevAverage = previousWeek.fold(0, (sum, e) => sum + e.moodScore) / previousWeek.length;

    return lastAverage - prevAverage;
  }

  // Most common emotional state
  String get mostCommonEmotionalState {
    if (entries.isEmpty) return 'Unknown';
    final states = <String, int>{};
    for (final entry in entries) {
      if (entry.emotionalState != null) {
        states[entry.emotionalState!] = (states[entry.emotionalState!] ?? 0) + 1;
      }
    }

    if (states.isEmpty) return 'Unknown';
    var mostCommon = '';
    var maxCount = 0;
    states.forEach((state, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommon = state;
      }
    });
    return mostCommon;
  }

  // Most common triggers
  List<String> get topTriggers {
    if (entries.isEmpty) return [];
    final triggerCounts = <String, int>{};
    for (final entry in entries) {
      for (final trigger in entry.triggers) {
        triggerCounts[trigger] = (triggerCounts[trigger] ?? 0) + 1;
      }
    }

    final sorted = triggerCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(5).map((e) => e.key).toList();
  }
}

// ==========================================
// OVERALL ANALYTICS
// ==========================================

class AnalyticsSnapshot {
  final MoodStats moodStats;
  final ExerciseStats exerciseStats;
  final SelfHelpStats selfHelpStats;
  final DateTime generatedAt;

  AnalyticsSnapshot({
    required this.moodStats,
    required this.exerciseStats,
    required this.selfHelpStats,
    DateTime? generatedAt,
  }) : generatedAt = generatedAt ?? DateTime.now();

  // Wellness score (0-100)
  int get wellnessScore {
    int score = 0;

    // Mood component (40%)
    final moodComponent = (moodStats.weeklyAverageMood / 10) * 40;
    score += moodComponent.round();

    // Exercise component (30%)
    final exerciseComponent = min(30, exerciseStats.totalSessions * 3).toDouble();
    score += exerciseComponent.round();

    // Self-help component (30%)
    final selfHelpComponent = min(30, selfHelpStats.totalActivities * 2).toDouble();
    score += selfHelpComponent.round();

    return min(100, score);
  }

  // Current streak (days)
  int get currentStreak {
    if (exerciseStats.sessions.isEmpty && moodStats.entries.isEmpty) return 0;

    final allEvents = <DateTime>[];
    for (final session in exerciseStats.sessions) {
      allEvents.add(session.completedAt);
    }
    for (final entry in moodStats.entries) {
      allEvents.add(entry.recordedAt);
    }

    if (allEvents.isEmpty) return 0;

    allEvents.sort((a, b) => b.compareTo(a));

    int streak = 0;
    var currentDate = DateTime.now();

    for (final date in allEvents) {
      final dateOnly = DateTime(date.year, date.month, date.day);
      final compareDate = DateTime(currentDate.year, currentDate.month, currentDate.day);

      if (dateOnly == compareDate || dateOnly == compareDate.subtract(Duration(days: streak + 1))) {
        streak++;
        if (streak > 1 && dateOnly != compareDate) {
          currentDate = date;
        }
      } else if (dateOnly.isBefore(compareDate)) {
        break;
      }
    }

    return streak;
  }
}

