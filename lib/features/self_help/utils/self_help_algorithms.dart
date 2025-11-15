import '../../../models/self_help/self_help_models.dart';

class SelfHelpAlgorithms {
  // ============================================
  // PERSONALIZED PLAN GENERATOR
  // ============================================
  
  static PersonalizedPlan generatePlan(UserAssessment assessment) {
    List<RecommendedAction> urgent = [];
    List<RecommendedAction> recommended = [];
    List<SuggestedProgram> programs = [];

    // Crisis handling
    if (assessment.mood == MoodType.crisis) {
      urgent.add(RecommendedAction(
        toolId: 'crisis_support',
        toolName: 'Crisis Support',
        priority: Priority.urgent,
        reason: 'Immediate support needed',
        estimatedDuration: 0,
      ));
      return PersonalizedPlan(
        urgentActions: urgent,
        recommendedTools: [],
        suggestedPrograms: [],
        summary: 'Immediate crisis support required. Please seek professional help.',
      );
    }

    // High anxiety handling
    if (assessment.anxietyLevel != null && assessment.anxietyLevel! >= 7) {
      urgent.add(RecommendedAction(
        toolId: 'box_breathing',
        toolName: 'Box Breathing',
        priority: Priority.urgent,
        reason: 'Quick relief for high anxiety',
        estimatedDuration: 5,
      ));
      urgent.add(RecommendedAction(
        toolId: '5_4_3_2_1_grounding',
        toolName: '5-4-3-2-1 Grounding',
        priority: Priority.urgent,
        reason: 'Ground yourself in the present',
        estimatedDuration: 5,
      ));
    }

    // Work stress handling
    if (assessment.triggers.contains('work_stress') &&
        (assessment.triggerIntensity['work_stress'] ?? 0) >= 7) {
      recommended.add(RecommendedAction(
        toolId: 'thought_record',
        toolName: 'Thought Challenging',
        priority: Priority.important,
        reason: 'Address work-related anxious thoughts',
        estimatedDuration: 15,
      ));
      recommended.add(RecommendedAction(
        toolId: 'pmr_quick',
        toolName: 'Quick Muscle Relaxation',
        priority: Priority.important,
        reason: 'Release physical tension from stress',
        estimatedDuration: 5,
      ));
    }

    // Low energy handling
    if (assessment.energyLevel <= 3) {
      recommended.add(RecommendedAction(
        toolId: 'behavioral_activation',
        toolName: 'Activity Scheduling',
        priority: Priority.important,
        reason: 'Plan mood-boosting activities',
        estimatedDuration: 10,
      ));
      recommended.add(RecommendedAction(
        toolId: 'gentle_yoga',
        toolName: 'Energizing Yoga',
        priority: Priority.routine,
        reason: 'Gentle movement to boost energy',
        estimatedDuration: 10,
      ));
    }

    // Sleep issues handling
    if (assessment.triggers.contains('sleep_issues')) {
      recommended.add(RecommendedAction(
        toolId: 'sleep_hygiene',
        toolName: 'Sleep Hygiene Guide',
        priority: Priority.important,
        reason: 'Improve sleep quality',
        estimatedDuration: 15,
      ));
      programs.add(SuggestedProgram(
        programId: 'sleep_restoration',
        reason: 'Address sleep issues and improve rest quality',
      ));
    }

    // Relationship issues
    if (assessment.triggers.contains('relationships')) {
      recommended.add(RecommendedAction(
        toolId: 'dbt_interpersonal',
        toolName: 'Communication Skills',
        priority: Priority.important,
        reason: 'Improve relationship interactions',
        estimatedDuration: 10,
      ));
    }

    // General mood improvement
    if (assessment.mood == MoodType.notGood || assessment.mood == MoodType.bad) {
      programs.add(SuggestedProgram(
        programId: 'anxiety_management',
        reason: 'Build coping skills for mood improvement',
      ));
      recommended.add(RecommendedAction(
        toolId: 'gratitude_journal',
        toolName: 'Gratitude Practice',
        priority: Priority.routine,
        reason: 'Shift focus to positives',
        estimatedDuration: 5,
      ));
    }

    return PersonalizedPlan(
      urgentActions: urgent,
      recommendedTools: recommended,
      suggestedPrograms: programs,
      summary: 'Personalized plan based on your current assessment.',
    );
  }

  // ============================================
  // PATTERN DETECTION
  // ============================================
  
  static List<Insight> detectPatterns(UserProgress progress) {
    List<Insight> insights = [];

    // Detect weekly mood patterns
    final moodByDayOfWeek = _groupMoodByDayOfWeek(progress.moodTrend);
    final lowestDay = _findLowestMoodDay(moodByDayOfWeek);

    if (lowestDay != null) {
      insights.add(Insight(
        type: InsightType.pattern,
        title: 'Weekly Pattern Detected',
        description: 'Your mood tends to be lower on ${lowestDay}s',
        actions: [
          'Create a ${lowestDay} morning routine',
          'Schedule self-care on ${lowestDay} evening',
          'Review your ${lowestDay} schedule for stressors',
        ],
      ));
    }

    // Detect successful tools
    // (This would need historical data about tool effectiveness)
    if (progress.totalActivitiesCompleted >= 10) {
      insights.add(Insight(
        type: InsightType.success,
        title: 'Consistency Pays Off!',
        description:
            'You\'ve completed ${progress.totalActivitiesCompleted} activities',
        actions: ['Keep up the great work!'],
      ));
    }

    // Streak encouragement
    if (progress.currentStreak >= 7) {
      insights.add(Insight(
        type: InsightType.success,
        title: '${progress.currentStreak}-Day Streak! 🔥',
        description: 'You\'re building a strong habit',
        actions: ['Maintain momentum with daily check-ins'],
      ));
    }

    return insights;
  }

  static Map<int, List<int>> _groupMoodByDayOfWeek(Map<String, int> moodTrend) {
    Map<int, List<int>> grouped = {};

    moodTrend.forEach((dateStr, moodScore) {
      final date = DateTime.parse(dateStr);
      final dayOfWeek = date.weekday; // 1 = Monday, 7 = Sunday

      if (!grouped.containsKey(dayOfWeek)) {
        grouped[dayOfWeek] = [];
      }
      grouped[dayOfWeek]!.add(moodScore);
    });

    return grouped;
  }

  static String? _findLowestMoodDay(Map<int, List<int>> moodByDayOfWeek) {
    if (moodByDayOfWeek.isEmpty) return null;

    Map<int, double> averages = {};
    moodByDayOfWeek.forEach((day, moods) {
      final avg = moods.reduce((a, b) => a + b) / moods.length;
      averages[day] = avg;
    });

    final lowestEntry =
        averages.entries.reduce((a, b) => a.value < b.value ? a : b);

    const dayNames = [
      '',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    return dayNames[lowestEntry.key];
  }

  // ============================================
  // COGNITIVE DISTORTION DETECTOR
  // ============================================
  
  static List<CognitiveDistortion> detectDistortions(String thought) {
    List<CognitiveDistortion> distortions = [];

    // All-or-nothing thinking
    if (_containsAnyOf(thought, [
      'always',
      'never',
      'every',
      'none',
      'all',
      'nothing',
      'completely',
      'totally'
    ])) {
      distortions.add(CognitiveDistortion.allOrNothing);
    }

    // Catastrophizing
    if (_containsAnyOf(thought, [
      'disaster',
      'catastrophe',
      'terrible',
      'awful',
      'worst',
      'horrible',
      'ruined'
    ])) {
      distortions.add(CognitiveDistortion.catastrophizing);
    }

    // Should statements
    if (_containsAnyOf(thought, ['should', 'must', 'ought', 'have to'])) {
      distortions.add(CognitiveDistortion.shouldStatements);
    }

    // Labeling
    if (_containsAnyOf(
        thought, ['I am', 'I\'m', 'he is', 'she is', 'they are'])) {
      if (_containsAnyOf(
          thought, ['stupid', 'failure', 'loser', 'worthless', 'useless'])) {
        distortions.add(CognitiveDistortion.labeling);
      }
    }

    return distortions;
  }

  static bool _containsAnyOf(String text, List<String> keywords) {
    final lowerText = text.toLowerCase();
    return keywords.any((keyword) => lowerText.contains(keyword.toLowerCase()));
  }
}