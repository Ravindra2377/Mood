import 'package:flutter/material.dart';

class QuickActionModel {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color background;

  const QuickActionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.background,
  });
}

class GuidedPathway {
  final String id;
  final String name;
  final int totalDays;
  final int currentDay;
  final double progress;
  final String focus;
  final int minutesToday;
  final List<DailyLesson> lessons;

  const GuidedPathway({
    required this.id,
    required this.name,
    required this.totalDays,
    required this.currentDay,
    required this.progress,
    required this.focus,
    required this.minutesToday,
    required this.lessons,
  });
}

class DailyLesson {
  final int day;
  final String title;
  final String summary;
  final List<LessonComponent> components;
  final bool isCompleted;
  final bool isUnlocked;

  const DailyLesson({
    required this.day,
    required this.title,
    required this.summary,
    required this.components,
    required this.isCompleted,
    required this.isUnlocked,
  });
}

class LessonComponent {
  final LessonComponentType type;
  final String title;
  final int minutes;

  const LessonComponent({
    required this.type,
    required this.title,
    required this.minutes,
  });
}

enum LessonComponentType { read, exercise, reflection, audio }

class TherapyFramework {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<TherapyTool> tools;

  const TherapyFramework({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.tools,
  });
}

class TherapyTool {
  final String id;
  final String title;
  final String subtitle;

  const TherapyTool({
    required this.id,
    required this.title,
    required this.subtitle,
  });
}

class AssessmentDescriptor {
  final String id;
  final String title;
  final String subtitle;
  final Duration duration;
  final int latestScore;
  final int previousScore;

  const AssessmentDescriptor({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.latestScore,
    required this.previousScore,
  });
}

class ResourceHighlight {
  final String id;
  final String title;
  final String type;
  final String metadata;

  const ResourceHighlight({
    required this.id,
    required this.title,
    required this.type,
    required this.metadata,
  });
}

class CrisisContact {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const CrisisContact({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class InsightHighlight {
  final String headline;
  final String detail;
  final List<InsightTrend> trends;

  const InsightHighlight({
    required this.headline,
    required this.detail,
    required this.trends,
  });
}

class InsightTrend {
  final String metric;
  final int current;
  final int previous;

  const InsightTrend({
    required this.metric,
    required this.current,
    required this.previous,
  });
}

class SupportCircle {
  final String id;
  final String name;
  final String description;
  final int members;

  const SupportCircle({
    required this.id,
    required this.name,
    required this.description,
    required this.members,
  });
}

class ActionPlanStep {
  final String category;
  final String title;
  final String description;
  final int minutes;

  const ActionPlanStep({
    required this.category,
    required this.title,
    required this.description,
    required this.minutes,
  });
}

class SelfHelpActionPlan {
  final String emotion;
  final String context;
  final List<ActionPlanStep> immediate;
  final List<ActionPlanStep> processing;
  final List<ActionPlanStep> building;
  final List<ActionPlanStep> learning;

  const SelfHelpActionPlan({
    required this.emotion,
    required this.context,
    required this.immediate,
    required this.processing,
    required this.building,
    required this.learning,
  });
}
