import '../../../models/self_help/self_help_models.dart';

class GuidedProgramsData {
  static List<GuidedProgram> getAllPrograms() {
    return [
      _anxietyManagement(),
      _sleepHygiene(),
      _depressionManagement(),
      _stressReduction(),
      _mindfulnessPractice(),
      _cognitiveRestructuring(),
    ];
  }

  static GuidedProgram _anxietyManagement() {
    return GuidedProgram(
      id: 'anxiety_management',
      title: 'Anxiety Management',
      description: 'Learn practical techniques to manage anxiety symptoms and build resilience.',
      category: ProgramCategory.anxiety,
      durationDays: 14,
      difficulty: ProgramDifficulty.beginner,
      estimatedTimePerDay: 15,
      modules: [
        ProgramModule(
          id: 'am_1',
          title: 'Understanding Anxiety',
          description: 'Learn what anxiety is and how it affects your body and mind.',
          day: 1,
          content: '''
Anxiety is your body's natural response to stress. It's designed to protect you from danger, but when it becomes excessive, it can interfere with daily life.

**What you'll learn today:**
- The difference between normal anxiety and anxiety disorders
- Common physical symptoms of anxiety
- How anxiety affects thoughts and behaviors

**Key Takeaway:** Anxiety is manageable. The techniques you'll learn in this program have helped millions of people regain control.
          ''',
          activities: [
            ProgramActivity(
              id: 'am_1_1',
              title: 'Track Your Anxiety',
              description: 'Notice when anxiety arises and what triggers it.',
              type: ActivityType.reflection,
              estimatedMinutes: 5,
            ),
          ],
        ),
        ProgramModule(
          id: 'am_2',
          title: 'Breathing Techniques',
          description: 'Master the 4-7-8 breathing method for immediate anxiety relief.',
          day: 2,
          content: '''
The 4-7-8 breathing technique is a powerful tool for calming your nervous system.

**How to practice:**
1. Inhale quietly through your nose for 4 seconds
2. Hold your breath for 7 seconds
3. Exhale completely through your mouth for 8 seconds
4. Repeat 4 times

**Practice this technique daily, especially when you feel anxious.**
          ''',
          activities: [
            ProgramActivity(
              id: 'am_2_1',
              title: 'Practice 4-7-8 Breathing',
              description: 'Complete 4 rounds of the breathing exercise.',
              type: ActivityType.practice,
              estimatedMinutes: 10,
            ),
          ],
        ),
        // Add more modules for full 14-day program...
      ],
      tags: ['anxiety', 'breathing', 'coping skills'],
      prerequisites: [],
      benefits: [
        'Reduced anxiety symptoms',
        'Better coping mechanisms',
        'Improved daily functioning',
      ],
    );
  }

  static GuidedProgram _sleepHygiene() {
    return GuidedProgram(
      id: 'sleep_hygiene',
      title: 'Sleep Hygiene',
      description: 'Establish healthy sleep habits for better rest and daytime energy.',
      category: ProgramCategory.sleep,
      durationDays: 10,
      difficulty: ProgramDifficulty.beginner,
      estimatedTimePerDay: 10,
      modules: [
        ProgramModule(
          id: 'sh_1',
          title: 'Sleep Basics',
          description: 'Understand the importance of sleep and common sleep disruptors.',
          day: 1,
          content: '''
Quality sleep is essential for physical health, mental clarity, and emotional well-being.

**Sleep facts:**
- Adults need 7-9 hours of sleep per night
- Poor sleep affects mood, memory, and immune function
- Sleep hygiene habits can significantly improve sleep quality

**Tonight's goal:** Aim for a consistent bedtime and wake-up time.
          ''',
          activities: [
            ProgramActivity(
              id: 'sh_1_1',
              title: 'Sleep Schedule Planning',
              description: 'Set a consistent sleep schedule for the week.',
              type: ActivityType.planning,
              estimatedMinutes: 5,
            ),
          ],
        ),
        // Add more modules...
      ],
      tags: ['sleep', 'hygiene', 'rest', 'energy'],
      prerequisites: [],
      benefits: [
        'Better sleep quality',
        'Increased daytime energy',
        'Improved mood and focus',
      ],
    );
  }

  static GuidedProgram _depressionManagement() {
    return GuidedProgram(
      id: 'depression_management',
      title: 'Depression Management',
      description: 'Build skills to manage depressive symptoms and increase activity levels.',
      category: ProgramCategory.depression,
      durationDays: 21,
      difficulty: ProgramDifficulty.intermediate,
      estimatedTimePerDay: 20,
      modules: [
        ProgramModule(
          id: 'dm_1',
          title: 'Understanding Depression',
          description: 'Learn about depression symptoms and the importance of behavioral activation.',
          day: 1,
          content: '''
Depression often creates a cycle where low mood leads to inactivity, which reinforces low mood.

**Behavioral activation** is a proven technique that breaks this cycle by encouraging small, meaningful activities.

**Key principle:** Action precedes motivation. Start small and build momentum.
          ''',
          activities: [
            ProgramActivity(
              id: 'dm_1_1',
              title: 'Identify Values',
              description: 'List 3-5 values that are important to you.',
              type: ActivityType.reflection,
              estimatedMinutes: 10,
            ),
          ],
        ),
        // Add more modules...
      ],
      tags: ['depression', 'behavioral activation', 'values', 'motivation'],
      prerequisites: [],
      benefits: [
        'Reduced depressive symptoms',
        'Increased activity levels',
        'Greater sense of purpose',
      ],
    );
  }

  static GuidedProgram _stressReduction() {
    return GuidedProgram(
      id: 'stress_reduction',
      title: 'Stress Reduction',
      description: 'Learn techniques to identify and manage stress in daily life.',
      category: ProgramCategory.stress,
      durationDays: 14,
      difficulty: ProgramDifficulty.beginner,
      estimatedTimePerDay: 15,
      modules: [
        ProgramModule(
          id: 'sr_1',
          title: 'Stress Awareness',
          description: 'Identify your personal stress triggers and responses.',
          day: 1,
          content: '''
Stress is your body's response to demands or challenges. While some stress is normal and even helpful, chronic stress can harm your health.

**Common stress responses:**
- Physical: Headaches, muscle tension, fatigue
- Emotional: Irritability, anxiety, depression
- Behavioral: Changes in eating/sleeping, withdrawal

**Today:** Notice your stress signals throughout the day.
          ''',
          activities: [
            ProgramActivity(
              id: 'sr_1_1',
              title: 'Stress Journal',
              description: 'Track stressful situations and your responses.',
              type: ActivityType.journaling,
              estimatedMinutes: 10,
            ),
          ],
        ),
        // Add more modules...
      ],
      tags: ['stress', 'relaxation', 'coping', 'mindfulness'],
      prerequisites: [],
      benefits: [
        'Better stress management',
        'Reduced physical tension',
        'Improved work-life balance',
      ],
    );
  }

  static GuidedProgram _mindfulnessPractice() {
    return GuidedProgram(
      id: 'mindfulness_practice',
      title: 'Mindfulness Practice',
      description: 'Develop present-moment awareness and reduce automatic negative thinking.',
      category: ProgramCategory.mindfulness,
      durationDays: 21,
      difficulty: ProgramDifficulty.intermediate,
      estimatedTimePerDay: 20,
      modules: [
        ProgramModule(
          id: 'mp_1',
          title: 'Introduction to Mindfulness',
          description: 'Learn the basics of mindfulness and begin a daily practice.',
          day: 1,
          content: '''
Mindfulness is the practice of being fully present and engaged with the current moment, without judgment.

**Benefits of mindfulness:**
- Reduced anxiety and depression
- Better emotional regulation
- Improved focus and concentration
- Enhanced self-awareness

**Daily practice:** Start with 5 minutes of mindful breathing each day.
          ''',
          activities: [
            ProgramActivity(
              id: 'mp_1_1',
              title: 'Mindful Breathing',
              description: 'Practice focused breathing for 5 minutes.',
              type: ActivityType.meditation,
              estimatedMinutes: 5,
            ),
          ],
        ),
        // Add more modules...
      ],
      tags: ['mindfulness', 'meditation', 'present moment', 'awareness'],
      prerequisites: [],
      benefits: [
        'Reduced rumination',
        'Better emotional control',
        'Increased life satisfaction',
      ],
    );
  }

  static GuidedProgram _cognitiveRestructuring() {
    return GuidedProgram(
      id: 'cognitive_restructuring',
      title: 'Cognitive Restructuring',
      description: 'Learn to identify and challenge negative thought patterns.',
      category: ProgramCategory.cognitive,
      durationDays: 21,
      difficulty: ProgramDifficulty.advanced,
      estimatedTimePerDay: 25,
      modules: [
        ProgramModule(
          id: 'cr_1',
          title: 'Thought Monitoring',
          description: 'Learn to identify automatic negative thoughts and cognitive distortions.',
          day: 1,
          content: '''
Our thoughts influence our emotions and behaviors. Cognitive restructuring helps you identify distorted thinking patterns and replace them with more balanced alternatives.

**Common cognitive distortions:**
- All-or-nothing thinking
- Overgeneralization
- Mental filtering
- Jumping to conclusions

**Practice:** Notice your thoughts throughout the day without judgment.
          ''',
          activities: [
            ProgramActivity(
              id: 'cr_1_1',
              title: 'Thought Journal',
              description: 'Record 3 automatic thoughts and identify any distortions.',
              type: ActivityType.journaling,
              estimatedMinutes: 15,
            ),
          ],
        ),
        // Add more modules...
      ],
      tags: ['cognitive', 'thoughts', 'distortions', 'restructuring'],
      prerequisites: ['anxiety_management'],
      benefits: [
        'More balanced thinking',
        'Reduced negative self-talk',
        'Improved problem-solving',
      ],
    );
  }
}