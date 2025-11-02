import 'package:uuid/uuid.dart';

// Enums
enum MoodType { great, good, okay, notGood, bad, crisis }
enum Priority { urgent, important, routine }
enum InsightType { pattern, success, warning, suggestion }
enum ComponentType { learn, exercise, practice }
enum CognitiveDistortion {
  allOrNothing,
  catastrophizing,
  mentalFilter,
  discountingPositive,
  jumpingToConclusions,
  magnification,
  emotionalReasoning,
  shouldStatements,
  labeling,
  personalization
}
enum ProgramCategory { anxiety, sleep, depression, stress, mindfulness, cognitive }
enum ProgramDifficulty { beginner, intermediate, advanced }
enum ActivityType { reflection, practice, planning, journaling, meditation }
enum ActionType { thoughtRecord, behavioralActivation, breathingExercise, journaling, mindfulness, professionalHelp }
enum ActionPriority { urgent, normal }
enum ResourceType { article, video, worksheet, audio }

// ============================================
// 1. USER ASSESSMENT MODEL
// ============================================

class UserAssessment {
  final String id;
  final DateTime timestamp;
  final MoodType mood;
  final int energyLevel; // 1-10
  final List<String> triggers;
  final Map<String, int> triggerIntensity; // trigger: intensity (1-10)
  final int? stressLevel; // 1-10
  final int? anxietyLevel; // 1-10

  UserAssessment({
    String? id,
    required this.timestamp,
    required this.mood,
    required this.energyLevel,
    required this.triggers,
    required this.triggerIntensity,
    this.stressLevel,
    this.anxietyLevel,
  }) : id = id ?? Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'mood': mood.toString().split('.').last,
        'energyLevel': energyLevel,
        'triggers': triggers,
        'triggerIntensity': triggerIntensity,
        'stressLevel': stressLevel,
        'anxietyLevel': anxietyLevel,
      };

  factory UserAssessment.fromJson(Map<String, dynamic> json) => UserAssessment(
        id: json['id'],
        timestamp: DateTime.parse(json['timestamp']),
        mood: MoodType.values.firstWhere(
          (e) => e.toString().split('.').last == json['mood'],
        ),
        energyLevel: json['energyLevel'],
        triggers: List<String>.from(json['triggers']),
        triggerIntensity: Map<String, int>.from(json['triggerIntensity']),
        stressLevel: json['stressLevel'],
        anxietyLevel: json['anxietyLevel'],
      );
}

// ============================================
// 2. PERSONALIZED PLAN MODEL
// ============================================

class PersonalizedPlan {
  final String id;
  final DateTime createdAt;
  final List<RecommendedAction> urgentActions;
  final List<RecommendedAction> recommendedTools;
  final List<SuggestedProgram> suggestedPrograms;
  final String summary;

  PersonalizedPlan({
    String? id,
    DateTime? createdAt,
    required this.urgentActions,
    required this.recommendedTools,
    required this.suggestedPrograms,
    required this.summary,
  })  : id = id ?? Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();
}

class RecommendedAction {
  final String id;
  final String toolId;
  final String toolName;
  final Priority priority;
  final String reason;
  final int estimatedDuration;

  RecommendedAction({
    String? id,
    required this.toolId,
    required this.toolName,
    required this.priority,
    required this.reason,
    required this.estimatedDuration,
  }) : id = id ?? Uuid().v4();
}

class SuggestedProgram {
  final String programId;
  final String reason;

  SuggestedProgram({
    required this.programId,
    required this.reason,
  });
}

// ============================================
// 3. CBT THOUGHT RECORD MODEL
// ============================================

class ThoughtRecord {
  final String id;
  final DateTime createdAt;
  final String situation;
  final String automaticThought;
  final int beliefRating; // 0-100
  final Map<String, int> emotions; // emotion: intensity (0-100)
  final List<String> evidenceFor;
  final List<String> evidenceAgainst;
  final List<CognitiveDistortion> distortions;
  final String alternativeThought;
  final int newBeliefRating; // 0-100
  final Map<String, int> newEmotions;

  ThoughtRecord({
    String? id,
    DateTime? createdAt,
    required this.situation,
    required this.automaticThought,
    required this.beliefRating,
    required this.emotions,
    required this.evidenceFor,
    required this.evidenceAgainst,
    required this.distortions,
    required this.alternativeThought,
    required this.newBeliefRating,
    required this.newEmotions,
  })  : id = id ?? Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  int get improvement => beliefRating - newBeliefRating;

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'situation': situation,
        'automaticThought': automaticThought,
        'beliefRating': beliefRating,
        'emotions': emotions,
        'evidenceFor': evidenceFor,
        'evidenceAgainst': evidenceAgainst,
        'distortions':
            distortions.map((d) => d.toString().split('.').last).toList(),
        'alternativeThought': alternativeThought,
        'newBeliefRating': newBeliefRating,
        'newEmotions': newEmotions,
      };
}

// ============================================
// 4. BEHAVIORAL ACTIVATION MODEL
// ============================================

class BehavioralActivation {
  final String id;
  final Map<String, int> values; // value: importance (1-5)
  final List<PlannedActivity> activities;
  final int weeklyGoal;

  BehavioralActivation({
    String? id,
    required this.values,
    required this.activities,
    required this.weeklyGoal,
  }) : id = id ?? Uuid().v4();

  int get completionRate {
    if (activities.isEmpty) return 0;
    final completed = activities.where((a) => a.isCompleted).length;
    return (completed / activities.length * 100).round();
  }
}

class PlannedActivity {
  final String id;
  final String name;
  final DateTime scheduledTime;
  final int duration; // minutes
  final String value; // which value it serves
  final int expectedMoodBoost; // 1-5
  bool isCompleted;
  int? actualMoodBoost;

  PlannedActivity({
    String? id,
    required this.name,
    required this.scheduledTime,
    required this.duration,
    required this.value,
    required this.expectedMoodBoost,
    this.isCompleted = false,
    this.actualMoodBoost,
  }) : id = id ?? Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'scheduledTime': scheduledTime.toIso8601String(),
        'duration': duration,
        'value': value,
        'expectedMoodBoost': expectedMoodBoost,
        'isCompleted': isCompleted,
        'actualMoodBoost': actualMoodBoost,
      };
}

// ============================================
// 5. GUIDED PROGRAM MODEL
// ============================================

class GuidedProgram {
  final String id;
  final String title;
  final String description;
  final ProgramCategory category;
  final int durationDays;
  final ProgramDifficulty difficulty;
  final int estimatedTimePerDay;
  final List<ProgramModule> modules;
  final List<String> tags;
  final List<String> prerequisites;
  final List<String> benefits;

  GuidedProgram({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.durationDays,
    required this.difficulty,
    required this.estimatedTimePerDay,
    required this.modules,
    this.tags = const [],
    this.prerequisites = const [],
    this.benefits = const [],
  });
}

class ProgramDay {
  final int dayNumber;
  final String title;
  final int estimatedMinutes;
  final List<LessonComponent> components;
  bool isCompleted;
  bool isUnlocked;

  ProgramDay({
    required this.dayNumber,
    required this.title,
    required this.estimatedMinutes,
    required this.components,
    this.isCompleted = false,
    this.isUnlocked = false,
  });
}

class LessonComponent {
  final ComponentType type;
  final String title;
  final String content;
  final int duration;
  bool isCompleted;

  LessonComponent({
    required this.type,
    required this.title,
    required this.content,
    required this.duration,
    this.isCompleted = false,
  });
}

class ProgramModule {
  final String id;
  final String title;
  final String description;
  final int day;
  final String content;
  final List<ProgramActivity> activities;

  ProgramModule({
    required this.id,
    required this.title,
    required this.description,
    required this.day,
    required this.content,
    required this.activities,
  });
}

class ProgramActivity {
  final String id;
  final String title;
  final String description;
  final ActivityType type;
  final int estimatedMinutes;

  ProgramActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.estimatedMinutes,
  });
}

// ============================================
// 6. USER PROGRESS MODEL
// ============================================

class UserProgress {
  final String userId;
  final int currentStreak;
  final int longestStreak;
  final int totalActivitiesCompleted;
  final Duration totalTimeInvested;
  final Map<String, int> moodTrend; // date: mood score (1-10)
  final List<Insight> insights;
  final Map<String, int> dimensions; // dimension: score (1-10)

  UserProgress({
    required this.userId,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalActivitiesCompleted = 0,
    this.totalTimeInvested = Duration.zero,
    this.moodTrend = const {},
    this.insights = const [],
    this.dimensions = const {},
  });

  int get wellnessScore {
    if (dimensions.isEmpty) return 0;
    final sum = dimensions.values.reduce((a, b) => a + b);
    final average = sum / dimensions.length;
    return (average * 10).round(); // Scale to 0-100
  }
}

class Insight {
  final String id;
  final InsightType type;
  final String title;
  final String description;
  final List<String> actions;
  final DateTime detectedAt;

  Insight({
    String? id,
    required this.type,
    required this.title,
    required this.description,
    required this.actions,
    DateTime? detectedAt,
  })  : id = id ?? Uuid().v4(),
        detectedAt = detectedAt ?? DateTime.now();
}

// ============================================
// 7. SAFETY PLAN MODEL
// ============================================

class SafetyPlan {
  final String id;
  final String userId;
  final List<String> warningSigns;
  final List<String> copingStrategies;
  final List<EmergencyContact> contacts;
  final List<String> professionalResources;
  final List<String> reasonsToLive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SafetyPlan({
    String? id,
    required this.userId,
    required this.warningSigns,
    required this.copingStrategies,
    required this.contacts,
    required this.professionalResources,
    required this.reasonsToLive,
    DateTime? createdAt,
    this.updatedAt,
  })  : id = id ?? Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();
}

class EmergencyContact {
  final String id;
  final String name;
  final String relationship;
  final String phone;
  final String? availability;

  EmergencyContact({
    String? id,
    required this.name,
    required this.relationship,
    required this.phone,
    this.availability,
  }) : id = id ?? Uuid().v4();
}

// ============================================
// 8. RESOURCE MODEL
// ============================================

class Resource {
  final String id;
  final String title;
  final String description;
  final ResourceType type;
  final String category;
  final int estimatedMinutes;
  final double rating;
  final int views;
  final String? url;
  final String? content;

  Resource({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.estimatedMinutes,
    this.rating = 0.0,
    this.views = 0,
    this.url,
    this.content,
  });
}