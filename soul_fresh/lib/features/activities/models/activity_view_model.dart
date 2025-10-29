import 'package:flutter/material.dart';

enum DifficultyLevel { easy, medium, hard }

class ActivityStats {
  final int streakDays;
  final int minutesToday;
  final int totalCompleted;
  final int weeklyGoalMinutes;

  const ActivityStats({
    required this.streakDays,
    required this.minutesToday,
    required this.totalCompleted,
    required this.weeklyGoalMinutes,
  });
}

class WellnessActivity {
  final String id;
  final String name;
  final String category;
  final int durationMinutes;
  final String shortDescription;
  final String iconEmoji;
  final Color categoryColor;
  final double rating;
  final int ratingCount;
  final int completionPercentage;
  final List<String> tags;
  final bool isPopular;
  final bool isRecommended;
  final DifficultyLevel difficulty;

  const WellnessActivity({
    required this.id,
    required this.name,
    required this.category,
    required this.durationMinutes,
    required this.shortDescription,
    required this.iconEmoji,
    required this.categoryColor,
    required this.rating,
    required this.ratingCount,
    required this.completionPercentage,
    required this.tags,
    required this.isPopular,
    required this.isRecommended,
    required this.difficulty,
  });
}
