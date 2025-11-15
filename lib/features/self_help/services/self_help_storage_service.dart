import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/self_help/self_help_models.dart';
import '../controllers/program_controller.dart';

class SelfHelpStorageService {
  static const String _assessmentsBox = 'assessments';
  static const String _progressBox = 'progress';
  static const String _thoughtRecordsBox = 'thought_records';
  static const String _behavioralActivationBox = 'behavioral_activation';
  static const String _programEnrollmentsBox = 'program_enrollments';

  // Initialize Hive (call this in main.dart)
  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox(_assessmentsBox);
    await Hive.openBox(_progressBox);
    await Hive.openBox(_thoughtRecordsBox);
    await Hive.openBox(_behavioralActivationBox);
    await Hive.openBox(_programEnrollmentsBox);
  }

  // ============================================
  // ASSESSMENTS
  // ============================================

  Future<void> saveAssessment(UserAssessment assessment) async {
    final box = Hive.box(_assessmentsBox);
    await box.put(assessment.id, assessment.toJson());
  }

  Future<List<UserAssessment>> getRecentAssessments({int limit = 10}) async {
    final box = Hive.box(_assessmentsBox);
    final values = box.values.toList();
    
    // Sort by timestamp (newest first)
    values.sort((a, b) {
      final dateA = DateTime.parse(a['timestamp']);
      final dateB = DateTime.parse(b['timestamp']);
      return dateB.compareTo(dateA);
    });

    return values
        .take(limit)
        .map((json) => UserAssessment.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  // ============================================
  // PROGRESS
  // ============================================

  Future<void> saveProgress(UserProgress progress) async {
    final box = Hive.box(_progressBox);
    await box.put('current', {
      'user_id': progress.userId,
      'current_streak': progress.currentStreak,
      'longest_streak': progress.longestStreak,
      'total_activities': progress.totalActivitiesCompleted,
      'total_time_minutes': progress.totalTimeInvested.inMinutes,
      'mood_trend': progress.moodTrend,
      'dimensions': progress.dimensions,
    });
  }

  Future<UserProgress> getProgress() async {
    final box = Hive.box(_progressBox);
    final data = box.get('current', defaultValue: {
      'user_id': 'current_user',
      'current_streak': 0,
      'longest_streak': 0,
      'total_activities': 0,
      'total_time_minutes': 0,
      'mood_trend': {},
      'dimensions': {},
    });

    return UserProgress(
      userId: data['user_id'],
      currentStreak: data['current_streak'],
      longestStreak: data['longest_streak'],
      totalActivitiesCompleted: data['total_activities'],
      totalTimeInvested: Duration(minutes: data['total_time_minutes']),
      moodTrend: Map<String, int>.from(data['mood_trend']),
      dimensions: Map<String, int>.from(data['dimensions']),
    );
  }

  // ============================================
  // THOUGHT RECORDS
  // ============================================

  Future<void> saveThoughtRecord(ThoughtRecord record) async {
    final box = Hive.box(_thoughtRecordsBox);
    await box.put(record.id, record.toJson());
  }

  Future<List<ThoughtRecord>> getThoughtRecords() async {
    final box = Hive.box(_thoughtRecordsBox);
    final values = box.values.toList();
    
    return values
        .map((json) => ThoughtRecord(
              id: json['id'],
              createdAt: DateTime.parse(json['createdAt']),
              situation: json['situation'],
              automaticThought: json['automaticThought'],
              beliefRating: json['beliefRating'],
              emotions: Map<String, int>.from(json['emotions']),
              evidenceFor: List<String>.from(json['evidenceFor']),
              evidenceAgainst: List<String>.from(json['evidenceAgainst']),
              distortions: (json['distortions'] as List)
                  .map((d) => CognitiveDistortion.values
                      .firstWhere((e) => e.toString().split('.').last == d))
                  .toList(),
              alternativeThought: json['alternativeThought'],
              newBeliefRating: json['newBeliefRating'],
              newEmotions: Map<String, int>.from(json['newEmotions']),
            ))
        .toList();
  }

  // ============================================
  // BEHAVIORAL ACTIVATION
  // ============================================

  Future<void> saveBehavioralActivation(BehavioralActivation activation) async {
    final box = Hive.box(_behavioralActivationBox);
    await box.put('current', {
      'id': activation.id,
      'values': activation.values,
      'activities':
          activation.activities.map((a) => a.toJson()).toList(),
      'weekly_goal': activation.weeklyGoal,
    });
  }

  Future<BehavioralActivation?> getBehavioralActivation() async {
    final box = Hive.box(_behavioralActivationBox);
    final data = box.get('current');
    
    if (data == null) return null;

    return BehavioralActivation(
      id: data['id'],
      values: Map<String, int>.from(data['values']),
      activities: (data['activities'] as List)
          .map((json) => PlannedActivity(
                id: json['id'],
                name: json['name'],
                scheduledTime: DateTime.parse(json['scheduledTime']),
                duration: json['duration'],
                value: json['value'],
                expectedMoodBoost: json['expectedMoodBoost'],
                isCompleted: json['isCompleted'],
                actualMoodBoost: json['actualMoodBoost'],
              ))
          .toList(),
      weeklyGoal: data['weekly_goal'],
    );
  }

  // ============================================
  // PROGRAM ENROLLMENTS
  // ============================================

  Future<void> saveProgramEnrollment(UserProgramEnrollment enrollment) async {
    final box = Hive.box(_programEnrollmentsBox);
    await box.put(enrollment.programId, {
      'program_id': enrollment.programId,
      'enrolled_at': enrollment.enrolledAt.toIso8601String(),
      'current_day': enrollment.currentDay,
      'completed_days': enrollment.completedDays,
      'is_completed': enrollment.isCompleted,
    });
  }

  Future<void> updateProgramEnrollment(UserProgramEnrollment enrollment) async {
    await saveProgramEnrollment(enrollment);
  }

  Future<List<UserProgramEnrollment>> getProgramEnrollments() async {
    final box = Hive.box(_programEnrollmentsBox);
    final values = box.values.toList();
    
    return values
        .map((data) => UserProgramEnrollment(
              programId: data['program_id'],
              enrolledAt: DateTime.parse(data['enrolled_at']),
              currentDay: data['current_day'],
              completedDays: List<int>.from(data['completed_days']),
              isCompleted: data['is_completed'],
            ))
        .toList();
  }
}