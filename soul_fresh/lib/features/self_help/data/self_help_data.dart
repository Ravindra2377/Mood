import 'package:flutter/material.dart';

import '../models/self_help_models.dart';

const String selfHelpUserName = 'Olivia';

const List<QuickActionModel> quickActions = <QuickActionModel>[
  QuickActionModel(
    id: 'crisis_help',
    title: 'Crisis Help',
    subtitle: 'Immediate support and safety plan',
    icon: Icons.volunteer_activism,
    background: Color(0xFFFFE0E0),
  ),
  QuickActionModel(
    id: 'calm_down',
    title: 'Calm Down',
    subtitle: 'Breathing and grounding toolkit',
    icon: Icons.self_improvement,
    background: Color(0xFFD7FBE8),
  ),
  QuickActionModel(
    id: 'check_in',
    title: 'Emotion Check-In',
    subtitle: 'Capture how you feel in seconds',
    icon: Icons.favorite_border,
    background: Color(0xFFE7E7FF),
  ),
  QuickActionModel(
    id: 'start_chat',
    title: 'Ask SOUL AI',
    subtitle: 'Talk through anything, anytime',
    icon: Icons.smart_toy_outlined,
    background: Color(0xFFE1F2FF),
  ),
];

final List<GuidedPathway> guidedPathways = <GuidedPathway>[
  GuidedPathway(
    id: 'anxiety_reset',
    name: '7-Day Anxiety Reset',
    totalDays: 7,
    currentDay: 3,
    progress: 0.43,
    focus: 'Today: Thought Challenging',
    minutesToday: 25,
    lessons: List<DailyLesson>.generate(7, (int index) {
      final int day = index + 1;
      return DailyLesson(
        day: day,
        title: switch (day) {
          1 => 'Understanding Anxiety',
          2 => 'Breathing Toolkit',
          3 => 'Thought Challenging',
          4 => 'Grounding and Presence',
          5 => 'Building Resilience',
          6 => 'Sleep and Reset',
          _ => 'Maintenance Plan',
        },
        summary: 'Daily micro-lesson with practices and reflection.',
        components: const <LessonComponent>[
          LessonComponent(
            type: LessonComponentType.read,
            title: 'Learn',
            minutes: 10,
          ),
          LessonComponent(
            type: LessonComponentType.exercise,
            title: 'Practice',
            minutes: 10,
          ),
          LessonComponent(
            type: LessonComponentType.reflection,
            title: 'Reflect',
            minutes: 5,
          ),
        ],
        isCompleted: day < 3,
        isUnlocked: day <= 3,
      );
    }),
  ),
  const GuidedPathway(
    id: 'sleep_restoration',
    name: '14-Day Sleep Restoration',
    totalDays: 14,
    currentDay: 5,
    progress: 0.29,
    focus: 'Tonight: Build Your Wind-Down Routine',
    minutesToday: 30,
    lessons: <DailyLesson>[],
  ),
  const GuidedPathway(
    id: 'depression_relief',
    name: '10-Day Depression Relief',
    totalDays: 10,
    currentDay: 2,
    progress: 0.18,
    focus: 'Today: Behavioral Activation',
    minutesToday: 20,
    lessons: <DailyLesson>[],
  ),
];

const List<TherapyFramework> therapyFrameworks = <TherapyFramework>[
  TherapyFramework(
    id: 'cbt',
    title: 'CBT Tools',
    description: 'Challenge thoughts and build helpful habits.',
    icon: Icons.pattern,
    color: Color(0xFF8C9EFF),
    tools: <TherapyTool>[
      TherapyTool(
        id: 'thought_record',
        title: 'Thought Record',
        subtitle: 'Capture and reframe anxious thinking.',
      ),
      TherapyTool(
        id: 'behavioral_experiment',
        title: 'Behavioral Experiments',
        subtitle: 'Test beliefs with real-world actions.',
      ),
      TherapyTool(
        id: 'mood_chart',
        title: 'Mood Chart',
        subtitle: 'Spot your emotional patterns quickly.',
      ),
    ],
  ),
  TherapyFramework(
    id: 'dbt',
    title: 'DBT Skills',
    description: 'Regulate emotions and navigate crises.',
    icon: Icons.all_inclusive,
    color: Color(0xFFFFC4A3),
    tools: <TherapyTool>[
      TherapyTool(
        id: 'tipp',
        title: 'TIPP Skills',
        subtitle: 'Cool your body to calm your mind fast.',
      ),
      TherapyTool(
        id: 'opposite_action',
        title: 'Opposite Action',
        subtitle: 'Shift your behavior to move emotions.',
      ),
      TherapyTool(
        id: 'wise_mind',
        title: 'Wise Mind',
        subtitle: 'Find balance between logic and emotion.',
      ),
    ],
  ),
  TherapyFramework(
    id: 'act',
    title: 'ACT Guide',
    description: 'Live by your values with acceptance.',
    icon: Icons.auto_awesome,
    color: Color(0xFF80DEEA),
    tools: <TherapyTool>[
      TherapyTool(
        id: 'values_map',
        title: 'Values Map',
        subtitle: 'Name what matters most right now.',
      ),
      TherapyTool(
        id: 'defusion',
        title: 'Defusion Practices',
        subtitle: 'Unhook from intrusive thoughts.',
      ),
      TherapyTool(
        id: 'committed_action',
        title: 'Committed Action',
        subtitle: 'Plan one value-based action today.',
      ),
    ],
  ),
];

const List<AssessmentDescriptor> assessmentCatalog = <AssessmentDescriptor>[
  AssessmentDescriptor(
    id: 'gad7',
    title: 'GAD-7 Anxiety Check',
    subtitle: '7 questions • clinically validated',
    duration: Duration(minutes: 2),
    latestScore: 12,
    previousScore: 15,
  ),
  AssessmentDescriptor(
    id: 'phq9',
    title: 'PHQ-9 Mood Check',
    subtitle: 'Monitor depressive symptoms',
    duration: Duration(minutes: 3),
    latestScore: 9,
    previousScore: 11,
  ),
  AssessmentDescriptor(
    id: 'pss',
    title: 'Perceived Stress Scale',
    subtitle: 'Understand your stress baseline',
    duration: Duration(minutes: 4),
    latestScore: 18,
    previousScore: 21,
  ),
];

const List<ResourceHighlight> resourceHighlights = <ResourceHighlight>[
  ResourceHighlight(
    id: 'article_anxiety',
    title: 'Understanding Anxiety Loops',
    type: 'Article',
    metadata: '8 min read • ⭐ 4.9',
  ),
  ResourceHighlight(
    id: 'video_cbt',
    title: 'CBT Thought Challenging Demo',
    type: 'Video',
    metadata: '12 min • 👁 12.5k',
  ),
  ResourceHighlight(
    id: 'worksheet_sleep',
    title: 'Sleep Ritual Planner (PDF)',
    type: 'Worksheet',
    metadata: 'Download • 3 pages',
  ),
  ResourceHighlight(
    id: 'podcast_self_compassion',
    title: 'Micro-moments of Self-Compassion',
    type: 'Podcast',
    metadata: '18 min episode',
  ),
];

const List<CrisisContact> crisisContacts = <CrisisContact>[
  CrisisContact(
    id: '911',
    title: 'Call 911',
    description: 'If you are in immediate danger',
    icon: Icons.local_phone,
    color: Color(0xFFFF8A80),
  ),
  CrisisContact(
    id: '988',
    title: '988 Lifeline',
    description: 'Call, text, or chat with counselors',
    icon: Icons.support_agent,
    color: Color(0xFFFFAB91),
  ),
  CrisisContact(
    id: 'text_home',
    title: 'Text HOME to 741741',
    description: 'Crisis Text Line • Available 24/7',
    icon: Icons.sms,
    color: Color(0xFFFFCC80),
  ),
];

const InsightHighlight weeklyInsight = InsightHighlight(
  headline: 'Your anxiety peaks on Monday mornings',
  detail:
      'Evening meditation lowered your anxiety by 15%. Keep the streak going!',
  trends: <InsightTrend>[
    InsightTrend(metric: 'Anxiety', current: 61, previous: 72),
    InsightTrend(metric: 'Sleep', current: 78, previous: 65),
    InsightTrend(metric: 'Activities', current: 18, previous: 12),
  ],
);

const List<SupportCircle> supportCircles = <SupportCircle>[
  SupportCircle(
    id: 'anxiety_warriors',
    name: 'Anxiety Warriors',
    description: 'Share wins and setbacks with people who truly get it.',
    members: 8231,
  ),
  SupportCircle(
    id: 'sleep_collective',
    name: 'Sleep Better Collective',
    description: 'Trade routines, hacks, and encouragement for better rest.',
    members: 5120,
  ),
  SupportCircle(
    id: 'grief_circle',
    name: 'Grief & Loss Circle',
    description: 'Compassionate space to honor and process loss.',
    members: 2744,
  ),
];

const Map<String, List<String>> emotionTriggerSuggestions =
    <String, List<String>>{
  'Anxious': <String>[
    'Work/School',
    'Relationships',
    'Health',
    'Money worries',
    'Upcoming event',
  ],
  'Sad': <String>['Loneliness', 'Loss', 'Weather', 'Unexpected setback'],
  'Angry': <String>['Conflict', 'Unfairness', 'Broken boundary'],
  'Overwhelmed': <String>['Too many tasks', 'Uncertainty', 'Expectations'],
  'Tired': <String>['Lack of sleep', 'Overthinking', 'Burnout'],
  'Numb': <String>['Disconnection', 'Low energy', 'Routine stuck'],
  'Happy': <String>['Gratitude', 'Connection', 'Achievement'],
  'Confused': <String>['Mixed signals', 'Decision fatigue', 'Change'],
};

const Map<String, SelfHelpActionPlan> emotionActionPlans =
    <String, SelfHelpActionPlan>{
  'Anxious': SelfHelpActionPlan(
    emotion: 'Anxious',
    context: 'Moderate-High anxiety about upcoming events',
    immediate: <ActionPlanStep>[
      ActionPlanStep(
        category: 'Immediate relief',
        title: 'Box Breathing (4-4-4-4)',
        description: 'Slow nervous system in three minutes.',
        minutes: 3,
      ),
      ActionPlanStep(
        category: 'Immediate relief',
        title: '5-4-3-2-1 Grounding',
        description: 'Bring attention back to the present.',
        minutes: 5,
      ),
    ],
    processing: <ActionPlanStep>[
      ActionPlanStep(
        category: 'Process the worry',
        title: 'Thought Challenging Worksheet',
        description: 'Capture anxious predictions and reframe.',
        minutes: 12,
      ),
      ActionPlanStep(
        category: 'Process the worry',
        title: 'Worry Time Scheduling',
        description: 'Contain rumination to a planned 10-minute window.',
        minutes: 10,
      ),
    ],
    building: <ActionPlanStep>[
      ActionPlanStep(
        category: 'Build confidence',
        title: 'Success Visualization',
        description: 'Mentally rehearse the event going well.',
        minutes: 8,
      ),
      ActionPlanStep(
        category: 'Build confidence',
        title: 'Strength Inventory',
        description: 'List three times you handled similar stress.',
        minutes: 5,
      ),
    ],
    learning: <ActionPlanStep>[
      ActionPlanStep(
        category: 'Learn more',
        title: 'Article: Pre-event Anxiety Toolkit',
        description: 'Evidence-based strategies to stay grounded.',
        minutes: 6,
      ),
      ActionPlanStep(
        category: 'Learn more',
        title: 'Video: Power of Preparedness',
        description: '3-minute micro-lesson from SOUL coaches.',
        minutes: 3,
      ),
    ],
  ),
  'Sad': SelfHelpActionPlan(
    emotion: 'Sad',
    context: 'Low mood with moderate intensity',
    immediate: <ActionPlanStep>[
      ActionPlanStep(
        category: 'Immediate relief',
        title: '5 Minute Movement Reset',
        description: 'Gentle stretches to shift stagnation.',
        minutes: 5,
      ),
      ActionPlanStep(
        category: 'Immediate relief',
        title: 'Self-Compassion Break',
        description: 'Short guided audio to soothe inner critic.',
        minutes: 4,
      ),
    ],
    processing: <ActionPlanStep>[
      ActionPlanStep(
        category: 'Process the feeling',
        title: 'Emotion Wheel Check-In',
        description: 'Name the precise feeling under the sadness.',
        minutes: 6,
      ),
      ActionPlanStep(
        category: 'Process the feeling',
        title: 'Gratitude Journal Prompt',
        description: 'Write three anchors that keep you steady.',
        minutes: 8,
      ),
    ],
    building: <ActionPlanStep>[
      ActionPlanStep(
        category: 'Build support',
        title: 'Reach Out to a Supportive Person',
        description: 'Share one honest sentence with someone safe.',
        minutes: 5,
      ),
      ActionPlanStep(
        category: 'Build support',
        title: 'Plan a Nourishing Activity',
        description: 'Schedule one thing that brings gentle joy.',
        minutes: 10,
      ),
    ],
    learning: <ActionPlanStep>[
      ActionPlanStep(
        category: 'Learn more',
        title: 'Article: Why Sadness Matters',
        description: 'Understand the signal your emotion sends.',
        minutes: 7,
      ),
      ActionPlanStep(
        category: 'Learn more',
        title: 'Podcast: Holding Space for Grief',
        description: 'Guided reflection from SOUL therapists.',
        minutes: 12,
      ),
    ],
  ),
};
