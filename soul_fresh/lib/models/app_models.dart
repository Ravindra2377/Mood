// Models for the mental health app
import 'package:flutter/material.dart';

enum MoodLevel {
  angry,
  sad,
  neutral,
  happy,
  veryHappy,
}

enum TimeFilter {
  today,
  nextWeek,
  nextMonth,
}

enum ActivityType {
  yoga,
  journal,
  exercises,
  practices,
  meditation,
}

enum ContentType {
  article,
  video,
  audio,
}

enum NavigationSection {
  home,
  journal,
  analytics,
  settings,
}

enum DayOfWeek {
  mon,
  tue,
  wed,
  thu,
  fri,
  sat,
  sun,
}

class Activity {
  final String id;
  final ActivityType type;
  final String title;
  final Color color;
  final IconData icon;

  const Activity({
    required this.id,
    required this.type,
    required this.title,
    required this.color,
    required this.icon,
  });
}

class ActivityStat {
  final String id;
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const ActivityStat({
    required this.id,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });
}

class PhysicalState {
  final double percentage;
  final String sleepGoal;
  final String lastNight;
  final String deficit;

  const PhysicalState({
    required this.percentage,
    required this.sleepGoal,
    required this.lastNight,
    required this.deficit,
  });
}

class CalendarDay {
  final DayOfWeek day;
  final int date;
  final bool isSelected;

  const CalendarDay({
    required this.day,
    required this.date,
    required this.isSelected,
  });
}

class Quote {
  final String text;
  final String author;

  const Quote({
    required this.text,
    required this.author,
  });
}

class ContentItem {
  final String id;
  final ContentType type;
  final String title;
  final String duration;
  final String thumbnail;

  const ContentItem({
    required this.id,
    required this.type,
    required this.title,
    required this.duration,
    required this.thumbnail,
  });
}

class MoodHistoryItem {
  final DateTime date;
  final MoodLevel mood;
  final int value;

  const MoodHistoryItem({
    required this.date,
    required this.mood,
    required this.value,
  });
}