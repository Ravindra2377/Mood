// Exercise Categories
enum ExerciseCategory {
  breathing,
  progressiveMuscleRelaxation,
  grounding,
  cognitiveBehavioral,
  journaling,
  visualization,
  movement,
  anxiety,
  sleep,
  emotionalRegulation,
  socialConnection,
  gamification,
  quickRelief,
}

// Exercise Difficulty
enum ExerciseDifficulty { easy, medium, hard }

// Exercise Status
enum ExerciseStatus { notStarted, inProgress, completed }

class Exercise {
  final String id;
  final String name;
  final ExerciseCategory category;
  final ExerciseDifficulty difficulty;
  final int durationSeconds;
  final String description;
  final List<String> instructions;
  final List<String> benefits;
  final String emoji;
  final String? audioUrl;
  final String? videoUrl;
  final int completions; // Total completions by all users
  final double rating;

  const Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.durationSeconds,
    required this.description,
    required this.instructions,
    required this.benefits,
    required this.emoji,
    this.audioUrl,
    this.videoUrl,
    this.completions = 0,
    this.rating = 0.0,
  });

  String get categoryName {
    switch (category) {
      case ExerciseCategory.breathing:
        return 'Breathing';
      case ExerciseCategory.progressiveMuscleRelaxation:
        return 'PMR';
      case ExerciseCategory.grounding:
        return 'Grounding';
      case ExerciseCategory.cognitiveBehavioral:
        return 'Cognitive';
      case ExerciseCategory.journaling:
        return 'Journaling';
      case ExerciseCategory.visualization:
        return 'Visualization';
      case ExerciseCategory.movement:
        return 'Movement';
      case ExerciseCategory.anxiety:
        return 'Anxiety';
      case ExerciseCategory.sleep:
        return 'Sleep';
      case ExerciseCategory.emotionalRegulation:
        return 'Emotions';
      case ExerciseCategory.socialConnection:
        return 'Social';
      case ExerciseCategory.gamification:
        return 'Games';
      case ExerciseCategory.quickRelief:
        return 'Quick Relief';
    }
  }

  String get difficultyLabel {
    switch (difficulty) {
      case ExerciseDifficulty.easy:
        return 'Easy';
      case ExerciseDifficulty.medium:
        return 'Medium';
      case ExerciseDifficulty.hard:
        return 'Hard';
    }
  }

  String get durationLabel {
    if (durationSeconds < 60) return '${durationSeconds}s';
    return '${(durationSeconds / 60).toStringAsFixed(0)} min';
  }
}

class ExerciseSession {
  final String id;
  final String userId;
  final String exerciseId;
  final DateTime startTime;
  final DateTime? endTime;
  final int? durationSeconds;
  final int moodBefore; // 1-10
  final int? moodAfter;
  final int? rating; // 1-5 stars
  final String? notes;

  ExerciseSession({
    required this.id,
    required this.userId,
    required this.exerciseId,
    required this.startTime,
    this.endTime,
    this.durationSeconds,
    required this.moodBefore,
    this.moodAfter,
    this.rating,
    this.notes,
  });

  bool get isCompleted => endTime != null && moodAfter != null;
}

// Mock exercises data
final List<Exercise> mockExercises = [
  // Breathing Exercises
  const Exercise(
    id: 'box-breathing',
    name: 'Box Breathing',
    category: ExerciseCategory.breathing,
    difficulty: ExerciseDifficulty.easy,
    durationSeconds: 300, // 5 min
    description: 'Reduces anxiety and improves focus with 4-4-4-4 pattern',
    instructions: [
      'Inhale for 4 seconds',
      'Hold for 4 seconds',
      'Exhale for 4 seconds',
      'Hold for 4 seconds',
      'Repeat 5 times',
    ],
    benefits: ['Reduces anxiety', 'Improves focus', 'Calms nervous system'],
    emoji: '🫁',
    completions: 2345,
    rating: 4.8,
  ),
  const Exercise(
    id: '4-7-8-breathing',
    name: '4-7-8 Breathing',
    category: ExerciseCategory.breathing,
    difficulty: ExerciseDifficulty.medium,
    durationSeconds: 300,
    description: 'Perfect for sleep and stress relief',
    instructions: [
      'Inhale through nose for 4 counts',
      'Hold for 7 counts',
      'Exhale through mouth for 8 counts',
      'Repeat 4 times',
    ],
    benefits: ['Better sleep', 'Stress relief', 'Calms anxiety'],
    emoji: '😴',
    completions: 1890,
    rating: 4.7,
  ),
  const Exercise(
    id: 'resonant-breathing',
    name: 'Resonant Breathing',
    category: ExerciseCategory.breathing,
    difficulty: ExerciseDifficulty.easy,
    durationSeconds: 600, // 10 min
    description: 'Balances nervous system with wave pattern (5-5)',
    instructions: [
      'Inhale for 5 seconds',
      'Exhale for 5 seconds',
      'Continue for 10 minutes',
      'Focus on smooth, even breaths',
    ],
    benefits: ['Nervous system balance', 'Heart rate regulation', 'Calm focus'],
    emoji: '🌊',
    completions: 1234,
    rating: 4.6,
  ),
  const Exercise(
    id: 'alternate-nostril',
    name: 'Alternate Nostril Breathing',
    category: ExerciseCategory.breathing,
    difficulty: ExerciseDifficulty.medium,
    durationSeconds: 300,
    description: 'Left nostril → Hold → Right nostril → Hold pattern',
    instructions: [
      'Close right nostril, inhale left',
      'Close left nostril, exhale right',
      'Inhale right, exhale left',
      'Repeat 10 times',
    ],
    benefits: ['Mental clarity', 'Balance energy', 'Reduces stress'],
    emoji: '👃',
    completions: 890,
    rating: 4.5,
  ),

  // Progressive Muscle Relaxation
  const Exercise(
    id: 'full-body-pmr',
    name: 'Full Body PMR',
    category: ExerciseCategory.progressiveMuscleRelaxation,
    difficulty: ExerciseDifficulty.medium,
    durationSeconds: 1200, // 20 min
    description: 'Complete muscle group relaxation from toes to face',
    instructions: [
      'Tense each muscle group for 5 seconds',
      'Release and notice the relaxation',
      'Move through: Toes → Legs → Abdomen → Chest → Arms → Shoulders → Neck → Face',
      'End with full body relaxation',
    ],
    benefits: ['Reduces physical tension', 'Deep relaxation', 'Better sleep'],
    emoji: '💪',
    completions: 1567,
    rating: 4.9,
  ),
  const Exercise(
    id: 'quick-pmr',
    name: 'Quick PMR (5 min)',
    category: ExerciseCategory.progressiveMuscleRelaxation,
    difficulty: ExerciseDifficulty.easy,
    durationSeconds: 300,
    description: 'Focus on main tension areas',
    instructions: [
      'Tense shoulders → Release',
      'Tense jaw → Release',
      'Tense hands → Release',
      'Tense forehead → Release',
      'Full body relaxation',
    ],
    benefits: ['Quick tension relief', 'Improves focus', 'Reduces headaches'],
    emoji: '⚡',
    completions: 2100,
    rating: 4.8,
  ),

  // Grounding Techniques
  const Exercise(
    id: '5-4-3-2-1-sensory',
    name: '5-4-3-2-1 Sensory',
    category: ExerciseCategory.grounding,
    difficulty: ExerciseDifficulty.easy,
    durationSeconds: 300,
    description: 'Ground yourself using all 5 senses',
    instructions: [
      'Name 5 things you can see',
      'Name 4 things you can touch',
      'Name 3 things you can hear',
      'Name 2 things you can smell',
      'Name 1 thing you can taste',
    ],
    benefits: ['Panic attack relief', 'Anxiety reduction', 'Mental clarity'],
    emoji: '🌍',
    completions: 3421,
    rating: 4.9,
  ),

  // CBT Exercises
  const Exercise(
    id: 'thought-challenging',
    name: 'Thought Challenging',
    category: ExerciseCategory.cognitiveBehavioral,
    difficulty: ExerciseDifficulty.medium,
    durationSeconds: 900, // 15 min
    description: 'Challenge and reframe negative thoughts',
    instructions: [
      'Identify negative thought',
      'What\'s evidence for it?',
      'What\'s evidence against it?',
      'Create alternative perspective',
      'Write balanced thought',
    ],
    benefits: ['Reduces anxiety', 'Better thinking patterns', 'Mood improvement'],
    emoji: '🧠',
    completions: 1876,
    rating: 4.7,
  ),
  const Exercise(
    id: 'worry-time',
    name: 'Worry Time Scheduling',
    category: ExerciseCategory.cognitiveBehavioral,
    difficulty: ExerciseDifficulty.easy,
    durationSeconds: 900,
    description: 'Designate 15 min daily for worrying, postpone others',
    instructions: [
      'Set 15-minute timer',
      'Write down all worries',
      'After timer: postpone worries until tomorrow',
      'Redirect thoughts when worries appear',
      'Practice daily',
    ],
    benefits: ['Reduces rumination', 'Better control', 'Anxiety relief'],
    emoji: '⏰',
    completions: 1234,
    rating: 4.6,
  ),

  // Journaling
  const Exercise(
    id: 'stream-consciousness',
    name: 'Stream of Consciousness',
    category: ExerciseCategory.journaling,
    difficulty: ExerciseDifficulty.easy,
    durationSeconds: 600, // 10 min
    description: 'Write continuously without stopping or judging',
    instructions: [
      'Set 10-minute timer',
      'Write continuously without editing',
      'Don\'t worry about grammar or meaning',
      'Let thoughts flow naturally',
      'Read back if desired',
    ],
    benefits: ['Emotional clarity', 'Stress relief', 'Self-discovery'],
    emoji: '✍️',
    completions: 2543,
    rating: 4.8,
  ),
  const Exercise(
    id: 'gratitude-journal',
    name: 'Gratitude Journal',
    category: ExerciseCategory.journaling,
    difficulty: ExerciseDifficulty.easy,
    durationSeconds: 300,
    description: 'List 3 things you\'re grateful for',
    instructions: [
      'Write 3 specific things you\'re grateful for today',
      'For each, write why it matters',
      'Notice how gratitude feels',
      'Practice daily for best results',
    ],
    benefits: ['Improved mood', 'Better perspective', 'Happiness increase'],
    emoji: '🙏',
    completions: 3890,
    rating: 4.9,
  ),

  // Visualization
  const Exercise(
    id: 'safe-place-visualization',
    name: 'Safe Place Visualization',
    category: ExerciseCategory.visualization,
    difficulty: ExerciseDifficulty.medium,
    durationSeconds: 600, // 10 min
    description: 'Create detailed mental sanctuary with all 5 senses',
    instructions: [
      'Close eyes and imagine safe place',
      'Engage all 5 senses - what do you see, hear, smell, feel, taste?',
      'Notice colors, textures, sounds',
      'Stay here for 10 minutes',
      'Return whenever needed',
    ],
    benefits: ['Deep relaxation', 'Anxiety relief', 'Self-soothing tool'],
    emoji: '🌅',
    completions: 2176,
    rating: 4.8,
  ),
  const Exercise(
    id: 'success-visualization',
    name: 'Success Visualization',
    category: ExerciseCategory.visualization,
    difficulty: ExerciseDifficulty.medium,
    durationSeconds: 480,
    description: 'Visualize achieving your goal with emotions',
    instructions: [
      'Identify specific goal',
      'Close eyes and imagine success',
      'Feel the emotions of achievement',
      'Notice details - sights, sounds, feelings',
      'Reinforce positive feelings',
    ],
    benefits: ['Increased confidence', 'Better performance', 'Motivation boost'],
    emoji: '🎯',
    completions: 1654,
    rating: 4.7,
  ),

  // Movement
  const Exercise(
    id: 'gentle-yoga',
    name: 'Gentle Yoga Flow',
    category: ExerciseCategory.movement,
    difficulty: ExerciseDifficulty.easy,
    durationSeconds: 900, // 15 min
    description: 'Easy stretches: child pose, cat-cow, downward dog, twists',
    instructions: [
      'Child\'s Pose - 1 minute',
      'Cat-Cow Stretch - 2 minutes',
      'Downward Dog - 1 minute',
      'Seated Twists - 2 minutes',
      'Lying down relaxation - 9 minutes',
    ],
    benefits: ['Flexibility', 'Stress relief', 'Body awareness'],
    emoji: '🧘',
    completions: 2345,
    rating: 4.8,
  ),
  const Exercise(
    id: 'desk-stretches',
    name: 'Desk Stretches',
    category: ExerciseCategory.movement,
    difficulty: ExerciseDifficulty.easy,
    durationSeconds: 180,
    description: 'Quick stretches at desk: neck, shoulders, wrists, twists',
    instructions: [
      'Neck Rolls - 30 seconds',
      'Shoulder Shrugs - 30 seconds',
      'Wrist Circles - 30 seconds',
      'Seated Spinal Twist - 30 seconds',
      'Finish: Deep breathing',
    ],
    benefits: ['Tension relief', 'Improved circulation', 'Better focus'],
    emoji: '🪑',
    completions: 3210,
    rating: 4.7,
  ),

  // Anxiety Management
  const Exercise(
    id: 'tipp-skills',
    name: 'TIPP Skills (Crisis)',
    category: ExerciseCategory.anxiety,
    difficulty: ExerciseDifficulty.easy,
    durationSeconds: 300,
    description: 'Crisis intervention: Temperature, Intense exercise, Paced breathing, PMR',
    instructions: [
      'Temperature: Splash cold water on face',
      'Intense Exercise: 5 minutes of activity',
      'Paced Breathing: Slow, deep breaths',
      'Paired Muscle Relaxation: Tense and release muscles',
    ],
    benefits: ['Crisis relief', 'Immediate calming', 'Emotional regulation'],
    emoji: '🆘',
    completions: 876,
    rating: 4.9,
  ),
  const Exercise(
    id: 'stop-technique',
    name: 'STOP Technique',
    category: ExerciseCategory.anxiety,
    difficulty: ExerciseDifficulty.easy,
    durationSeconds: 180,
    description: 'Stop, Take step back, Observe, Proceed mindfully',
    instructions: [
      'Stop what you\'re doing',
      'Take a step back (literally or mentally)',
      'Observe thoughts and feelings without judgment',
      'Proceed mindfully with next action',
    ],
    benefits: ['Reaction control', 'Mindful response', 'Anxiety reduction'],
    emoji: '🛑',
    completions: 2134,
    rating: 4.8,
  ),

  // Sleep
  const Exercise(
    id: 'sleep-meditation',
    name: 'Sleep Meditation',
    category: ExerciseCategory.sleep,
    difficulty: ExerciseDifficulty.easy,
    durationSeconds: 1800, // 30 min
    description: 'Body scan and progressive relaxation for sleep',
    instructions: [
      'Lie down comfortably',
      'Body scan: notice sensations from head to toe',
      'Progressive relaxation of each body part',
      'Drift to sleep naturally',
    ],
    benefits: ['Better sleep', 'Relaxation', 'Insomnia relief'],
    emoji: '😴',
    completions: 3456,
    rating: 4.9,
  ),

  // Emotional Regulation
  const Exercise(
    id: 'emotion-wheel',
    name: 'Emotion Wheel Exercise',
    category: ExerciseCategory.emotionalRegulation,
    difficulty: ExerciseDifficulty.easy,
    durationSeconds: 300,
    description: 'Identify and understand specific emotions',
    instructions: [
      'Identify current emotion broadly (sad, angry, scared, happy)',
      'Use emotion wheel to get more specific',
      'Name precise emotion (melancholy, frustrated, anxious, joyful)',
      'Understand what triggered it',
      'Write about the emotion',
    ],
    benefits: ['Emotional awareness', 'Better regulation', 'Self-understanding'],
    emoji: '🎭',
    completions: 1876,
    rating: 4.7,
  ),

  // Quick Relief
  const Exercise(
    id: 'butterfly-hug',
    name: 'Butterfly Hug',
    category: ExerciseCategory.quickRelief,
    difficulty: ExerciseDifficulty.easy,
    durationSeconds: 120,
    description: 'Cross arms and tap alternately - instant soothing',
    instructions: [
      'Cross arms over chest',
      'Tap alternately - left shoulder, right shoulder',
      'Continue for 2 minutes',
      'Feel the soothing sensation',
    ],
    benefits: ['Instant calming', 'Stress relief', 'Self-soothing'],
    emoji: '🦋',
    completions: 2987,
    rating: 4.8,
  ),
  const Exercise(
    id: 'hand-warming',
    name: 'Hand Warming',
    category: ExerciseCategory.quickRelief,
    difficulty: ExerciseDifficulty.easy,
    durationSeconds: 180,
    description: 'Mentally warm your hands to shift nervous system',
    instructions: [
      'Sit comfortably',
      'Visualize warm light in your hands',
      'Imagine heat spreading',
      'Notice your hands actually warming',
    ],
    benefits: ['Nervous system shift', 'Grounding', 'Quick calm'],
    emoji: '🔥',
    completions: 654,
    rating: 4.6,
  ),
];
