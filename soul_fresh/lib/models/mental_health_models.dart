import 'package:flutter/foundation.dart';

/// Mental Health Data Models
/// All classes for tracking stress, mood, sleep, mindfulness, anxiety, and wellness

// ============ STRESS MODELS ============
class StressLog {
  final int id;
  final int level;
  final List<String> triggers;
  final String? notes;
  final DateTime timestamp;

  StressLog({
    required this.id,
    required this.level,
    required this.triggers,
    this.notes,
    required this.timestamp,
  });
}

class StressAnalytics {
  final double averageLevel;
  final String trend;
  final List<Map<String, dynamic>> topTriggers;
  final List<Map<String, dynamic>> effectiveExercises;

  StressAnalytics({
    required this.averageLevel,
    required this.trend,
    required this.topTriggers,
    required this.effectiveExercises,
  });
}

// ============ MOOD MODELS ============
class MoodEntry {
  final int id;
  final String emoji;
  final int level;
  final List<String> activities;
  final String? notes;
  final DateTime timestamp;

  MoodEntry({
    required this.id,
    required this.emoji,
    required this.level,
    required this.activities,
    this.notes,
    required this.timestamp,
  });
}

class MoodInsights {
  final double averageMood;
  final String trend;
  final List<String> topActivities;
  final Map<String, int> hourlyData;

  MoodInsights({
    required this.averageMood,
    required this.trend,
    required this.topActivities,
    required this.hourlyData,
  });
}

// ============ SLEEP MODELS ============
class SleepLog {
  final int id;
  final DateTime bedtime;
  final DateTime wakeTime;
  final int qualityRating;
  final String? notes;
  final DateTime date;

  SleepLog({
    required this.id,
    required this.bedtime,
    required this.wakeTime,
    required this.qualityRating,
    this.notes,
    required this.date,
  });

  int get sleepDurationHours {
    return wakeTime.difference(bedtime).inHours;
  }

  int get sleepDurationMinutes {
    return wakeTime.difference(bedtime).inMinutes % 60;
  }
}

class SleepAnalytics {
  final double averageSleep;
  final double averageQuality;
  final String trend;
  final List<Map<String, dynamic>> weeklyData;

  SleepAnalytics({
    required this.averageSleep,
    required this.averageQuality,
    required this.trend,
    required this.weeklyData,
  });
}

// ============ MINDFULNESS MODELS ============
class MeditationSession {
  final int id;
  final String name;
  final int durationMinutes;
  final String category;
  final DateTime timestamp;
  final bool completed;

  MeditationSession({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.category,
    required this.timestamp,
    required this.completed,
  });
}

class MindfulnessStats {
  final int totalSessions;
  final int totalMinutes;
  final int currentStreak;
  final int longestStreak;
  final List<Achievement> achievements;

  MindfulnessStats({
    required this.totalSessions,
    required this.totalMinutes,
    required this.currentStreak,
    required this.longestStreak,
    required this.achievements,
  });
}

class Achievement {
  final int id;
  final String name;
  final String description;
  final DateTime unlockedAt;
  final String icon;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.unlockedAt,
    required this.icon,
  });
}

// ============ ANXIETY MODELS ============
class AnxietyLog {
  final int id;
  final int intensity;
  final List<String> symptoms;
  final String? trigger;
  final String? copingStrategy;
  final DateTime timestamp;

  AnxietyLog({
    required this.id,
    required this.intensity,
    required this.symptoms,
    this.trigger,
    this.copingStrategy,
    required this.timestamp,
  });
}

class CopingStrategy {
  final int id;
  final String name;
  final String description;
  final int effectivenessRating;
  final int usageCount;

  CopingStrategy({
    required this.id,
    required this.name,
    required this.description,
    required this.effectivenessRating,
    required this.usageCount,
  });
}

class SafetyPlan {
  final int id;
  final List<String> warningSignals;
  final List<String> copingStrategies;
  final List<String> supportPersons;
  final List<String> emergencyContacts;
  final String? notes;

  SafetyPlan({
    required this.id,
    required this.warningSignals,
    required this.copingStrategies,
    required this.supportPersons,
    required this.emergencyContacts,
    this.notes,
  });
}

// ============ WELLNESS MODELS ============
class DailyCheckin {
  final int id;
  final DateTime date;
  final int physicalScore;
  final int mentalScore;
  final int emotionalScore;
  final String? notes;

  DailyCheckin({
    required this.id,
    required this.date,
    required this.physicalScore,
    required this.mentalScore,
    required this.emotionalScore,
    this.notes,
  });

  int get overallScore {
    return ((physicalScore + mentalScore + emotionalScore) / 3).round();
  }
}

class WellnessScore {
  final double physical;
  final double mental;
  final double emotional;
  final double social;
  final DateTime date;

  WellnessScore({
    required this.physical,
    required this.mental,
    required this.emotional,
    required this.social,
    required this.date,
  });

  double get overallScore {
    return (physical + mental + emotional + social) / 4;
  }
}

class WellnessGoal {
  final int id;
  final String category;
  final String title;
  final String description;
  final DateTime targetDate;
  final double progress;
  final bool completed;

  WellnessGoal({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.targetDate,
    required this.progress,
    required this.completed,
  });
}

// ============ USER MODELS ============
class UserProfile {
  final int id;
  final String email;
  final String? displayName;
  final String? avatar;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.id,
    required this.email,
    this.displayName,
    this.avatar,
    required this.createdAt,
    this.updatedAt,
  });
}

// ============ GENERAL MODELS ============
class TimeSeriesData {
  final DateTime timestamp;
  final double value;

  TimeSeriesData({
    required this.timestamp,
    required this.value,
  });
}

class AnalyticsReport {
  final String title;
  final String description;
  final List<TimeSeriesData> data;
  final double? average;
  final double? trend;

  AnalyticsReport({
    required this.title,
    required this.description,
    required this.data,
    this.average,
    this.trend,
  });
}
