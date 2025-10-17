import 'package:flutter/material.dart';
import '../models/app_models.dart';

// Mock data for the mental health app

class AppMockData {
  // User data
  static const String userName = "Olivia";
  static const String userAvatarUrl = "https://i.pravatar.cc/150?img=1";
  
  // Activities
  static final List<Activity> activities = [
    Activity(
      id: "act-1",
      type: ActivityType.yoga,
      title: "Yoga",
      color: const Color(0xFFE8B4F0),
      icon: Icons.self_improvement,
    ),
    Activity(
      id: "act-2",
      type: ActivityType.journal,
      title: "Journal",
      color: const Color(0xFFB4D4F0),
      icon: Icons.menu_book,
    ),
    Activity(
      id: "act-3",
      type: ActivityType.exercises,
      title: "Exercises",
      color: const Color(0xFFA8E6CF),
      icon: Icons.auto_awesome,
    ),
  ];

  // Activity statistics
  static final List<ActivityStat> activityStats = [
    ActivityStat(
      id: "stat-1",
      title: "Sleeping Time",
      value: "8h 34m",
      color: const Color(0xFFE8B4F0),
      icon: Icons.bedtime,
    ),
    ActivityStat(
      id: "stat-2",
      title: "Mood Level",
      value: "8/10",
      color: const Color(0xFFA8E6CF),
      icon: Icons.sentiment_satisfied,
    ),
    ActivityStat(
      id: "stat-3",
      title: "Active Time",
      value: "2h",
      color: const Color(0xFFFFE066),
      icon: Icons.directions_run,
    ),
  ];

  // Physical state
  static const PhysicalState physicalState = PhysicalState(
    percentage: 0.78,
    sleepGoal: "8h Target",
    lastNight: "7.5h Achieved",
    deficit: "1.5 Missing",
  );

  // Calendar week
  static final List<CalendarDay> calendarWeek = [
    const CalendarDay(day: DayOfWeek.mon, date: 21, isSelected: false),
    const CalendarDay(day: DayOfWeek.tue, date: 22, isSelected: true),
    const CalendarDay(day: DayOfWeek.wed, date: 23, isSelected: false),
    const CalendarDay(day: DayOfWeek.thu, date: 24, isSelected: false),
    const CalendarDay(day: DayOfWeek.fri, date: 25, isSelected: false),
    const CalendarDay(day: DayOfWeek.sat, date: 26, isSelected: false),
    const CalendarDay(day: DayOfWeek.sun, date: 27, isSelected: false),
  ];

  // Quote
  static const Quote quote = Quote(
    text: "Success is not final, failure is not fatal: it is the courage to continue that counts.",
    author: "Winston Churchill",
  );

  // Content items
  static final List<ContentItem> contentItems = [
    const ContentItem(
      id: "content-1",
      type: ContentType.article,
      title: "How to find balance in life despite...",
      duration: "4 min",
      thumbnail: "https://images.unsplash.com/photo-1526785033379-75ba86cfacf6?crop=entropy&cs=srgb&fm=jpg&ixid=M3w3NTAwNDR8MHwxfHNlYXJjaHw0fHxwZXJzb24lMjBtZWRpdGF0aW9uJTIwYmFsYW5jZSUyMHBlYWNlZnVsfGVufDB8Mnx8Ymx1ZXwxNzYwNjQwNzg0fDA&ixlib=rb-4.1.0&q=85",
    ),
    const ContentItem(
      id: "content-2",
      type: ContentType.video,
      title: "It's okay to ask for help, you're not alone",
      duration: "8 min",
      thumbnail: "https://images.unsplash.com/photo-1705405739947-9449cb52f143?crop=entropy&cs=srgb&fm=jpg&ixid=M3w3NTAwNDR8MHwxfHNlYXJjaHwxfHxicmFpbiUyMGNhcnRvb24lMjBjaGFyYWN0ZXIlMjBwaW5rfGVufDB8Mnx8cHVycGxlfDE3NjA2NDA3ODR8MA&ixlib=rb-4.1.0&q=85",
    ),
  ];

  // Mood history
  static final List<MoodHistoryItem> moodHistory = [
    MoodHistoryItem(
      date: DateTime.now().subtract(const Duration(days: 1)),
      mood: MoodLevel.neutral,
      value: 6,
    ),
    MoodHistoryItem(
      date: DateTime.now(),
      mood: MoodLevel.happy,
      value: 8,
    ),
  ];

  // Journal entry
  static const String journalEntryText = "Sometimes it feels like no matter what we do, things only get worse.";
  static const int journalCharacterCount = 68;
  static const int journalMaxCharacters = 240;

  // Ambient sounds
  static const List<String> ambientSounds = [
    "Ocean breeze",
    "Rain sounds",
    "Forest birds",
    "White noise",
    "Calm piano",
  ];
}