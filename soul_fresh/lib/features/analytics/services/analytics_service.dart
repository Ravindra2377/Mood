import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/analytics/analytics_models.dart';

class AnalyticsService {
  static const String _exerciseSessionsBox = 'exercise_sessions';
  static const String _selfHelpActivitiesBox = 'self_help_activities';
  static const String _moodEntriesBox = 'mood_entries';

  // Initialize Hive boxes
  static Future<void> initialize() async {
    await Hive.openBox<Map>(_exerciseSessionsBox);
    await Hive.openBox<Map>(_selfHelpActivitiesBox);
    await Hive.openBox<Map>(_moodEntriesBox);
  }

  // ==========================================
  // EXERCISE SESSION METHODS
  // ==========================================

  Future<void> saveExerciseSession(ExerciseSession session) async {
    final box = Hive.box<Map>(_exerciseSessionsBox);
    await box.put(session.id, session.toJson());
  }

  Future<ExerciseStats> getExerciseStats({
    int? days,
  }) async {
    final box = Hive.box<Map>(_exerciseSessionsBox);
    final sessions = box.values
        .map(
          (json) => ExerciseSession(
            id: json['id'],
            exerciseId: json['exerciseId'],
            exerciseName: json['exerciseName'],
            category: json['category'],
            durationMinutes: json['duration'],
            completedAt: DateTime.parse(json['completedAt']),
            moodBefore: json['moodBefore'],
            moodAfter: json['moodAfter'],
            notes: json['notes'],
          ),
        )
        .toList();

    if (days != null) {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      return ExerciseStats(
        sessions:
            sessions.where((s) => s.completedAt.isAfter(cutoffDate)).toList(),
      );
    }

    return ExerciseStats(sessions: sessions);
  }

  // ==========================================
  // SELF-HELP ACTIVITY METHODS
  // ==========================================

  Future<void> saveSelfHelpActivity(SelfHelpActivity activity) async {
    final box = Hive.box<Map>(_selfHelpActivitiesBox);
    await box.put(activity.id, activity.toJson());
  }

  Future<SelfHelpStats> getSelfHelpStats({
    int? days,
  }) async {
    final box = Hive.box<Map>(_selfHelpActivitiesBox);
    final activities = box.values
        .map(
          (json) => SelfHelpActivity(
            id: json['id'],
            activityType: json['activityType'],
            activityName: json['activityName'],
            durationMinutes: json['duration'],
            completedAt: DateTime.parse(json['completedAt']),
            completionPercentage: json['completionPercentage'],
            result: json['result'],
          ),
        )
        .toList();

    if (days != null) {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      return SelfHelpStats(
        activities:
            activities.where((a) => a.completedAt.isAfter(cutoffDate)).toList(),
      );
    }

    return SelfHelpStats(activities: activities);
  }

  // ==========================================
  // MOOD ENTRY METHODS
  // ==========================================

  Future<void> saveMoodEntry(MoodEntry entry) async {
    final box = Hive.box<Map>(_moodEntriesBox);
    await box.put(entry.id, entry.toJson());
  }

  Future<MoodStats> getMoodStats({
    int? days,
  }) async {
    final box = Hive.box<Map>(_moodEntriesBox);
    final entries = box.values
        .map(
          (json) => MoodEntry(
            id: json['id'],
            moodScore: json['moodScore'],
            emotionalState: json['emotionalState'],
            triggers: List<String>.from(json['triggers'] ?? []),
            recordedAt: DateTime.parse(json['recordedAt']),
          ),
        )
        .toList();

    if (days != null) {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      return MoodStats(
        entries:
            entries.where((e) => e.recordedAt.isAfter(cutoffDate)).toList(),
      );
    }

    return MoodStats(entries: entries);
  }

  // ==========================================
  // COMBINED ANALYTICS
  // ==========================================

  Future<AnalyticsSnapshot> getAnalyticsSnapshot({int days = 7}) async {
    final moodStats = await getMoodStats(days: days);
    final exerciseStats = await getExerciseStats(days: days);
    final selfHelpStats = await getSelfHelpStats(days: days);

    return AnalyticsSnapshot(
      moodStats: moodStats,
      exerciseStats: exerciseStats,
      selfHelpStats: selfHelpStats,
    );
  }
}
