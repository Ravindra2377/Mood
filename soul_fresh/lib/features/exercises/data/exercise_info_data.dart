import 'package:flutter/material.dart';

import '../models/exercise_info_model.dart';

class ExerciseInfoDatabase {
  static final Map<String, ExerciseInfo> _exercises = <String, ExerciseInfo>{
    'box_breathing': const ExerciseInfo(
      id: 'box_breathing',
      name: 'Box Breathing',
      category: 'Breathing',
      estimatedDuration: Duration(minutes: 5),
      icon: Icons.crop_square,
      color: Colors.blue,
      howItWorks:
          'Box breathing uses a 4-4-4-4 pattern: inhale for 4 seconds, hold for 4, exhale for 4, hold for 4. This equal-length rhythm regulates the nervous system.',
      benefits: <String>[
        'Reduces anxiety and stress quickly',
        'Lowers heart rate and blood pressure',
        'Improves focus and concentration',
        'Activates the parasympathetic system',
        'Easy to practice anywhere',
      ],
      whenToUse:
          'Before presentations, during panic, when overwhelmed, ahead of important meetings, or whenever you need rapid calm.',
      steps: <String>[
        'Sit comfortably with an upright posture.',
        'Inhale through your nose for four seconds.',
        'Hold your breath for four seconds.',
        'Exhale through your mouth for four seconds.',
        'Hold with empty lungs for four seconds.',
        'Repeat for 5-10 cycles or until calm.',
      ],
    ),
    '4_7_8_breathing': const ExerciseInfo(
      id: '4_7_8_breathing',
      name: '4-7-8 Breathing',
      category: 'Breathing',
      estimatedDuration: Duration(minutes: 3),
      icon: Icons.air,
      color: Colors.teal,
      howItWorks:
          'Inhale for four counts, hold for seven, and exhale for eight. The extended exhale activates the relaxation response.',
      benefits: <String>[
        'Induces deep relaxation',
        'Helps you fall asleep',
        'Manages anger and frustration',
        'Reduces anxiety symptoms',
        'Supports emotional regulation',
      ],
      whenToUse:
          'Ideal before sleep, when feeling angry, during anxious moments, or when transitioning between stressful activities. Avoid immediately before workouts.',
      steps: <String>[
        'Sit or lie down comfortably.',
        'Place the tip of your tongue behind your upper front teeth.',
        'Exhale completely through your mouth with a whooshing sound.',
        'Close your mouth, inhale through your nose for four counts.',
        'Hold your breath for seven counts.',
        'Exhale through your mouth for eight counts.',
        'Repeat three to four cycles.',
      ],
      warningNote:
          'May cause lightheadedness at first. Start with two to three cycles.',
    ),
    'resonant_breathing': const ExerciseInfo(
      id: 'resonant_breathing',
      name: 'Resonant Breathing',
      category: 'Breathing',
      estimatedDuration: Duration(minutes: 10),
      icon: Icons.waves,
      color: Colors.purple,
      howItWorks:
          'Breathing at roughly five seconds in and five seconds out maximizes heart rate variability and balances the nervous system.',
      benefits: <String>[
        'Improves heart rate variability',
        'Balances autonomic responses',
        'Reduces depressive symptoms',
        'Builds emotional resilience',
        'Enhances overall well-being',
      ],
      whenToUse:
          'Practice daily for 10-20 minutes, during meditation, or whenever you feel emotionally off balance.',
      steps: <String>[
        'Sit comfortably with a tall spine.',
        'Breathe through your nose naturally.',
        'Inhale slowly for five seconds.',
        'Exhale slowly for five seconds.',
        'Maintain smooth, even breaths.',
        'Continue for 10-20 minutes.',
        'Focus on rhythm rather than perfection.',
      ],
    ),
    'alternate_nostril': const ExerciseInfo(
      id: 'alternate_nostril',
      name: 'Alternate Nostril Breathing',
      category: 'Breathing',
      estimatedDuration: Duration(minutes: 5),
      icon: Icons.face,
      color: Colors.orange,
      howItWorks:
          'Nadi Shodhana alternates breathing between nostrils, supporting balance between brain hemispheres and a feeling of equilibrium.',
      benefits: <String>[
        'Balances brain hemispheres',
        'Boosts mental clarity and focus',
        'Reduces stress and anxiety',
        'Supports respiratory function',
        'Calms the nervous system',
      ],
      whenToUse:
          'Great in the morning, before meditation, or when you feel mentally scattered. Avoid if you have nasal congestion.',
      steps: <String>[
        'Sit comfortably and relax your shoulders.',
        'Close the right nostril with your thumb and inhale through the left for four counts.',
        'Close both nostrils and hold for four counts.',
        'Release the right nostril and exhale for four counts.',
        'Inhale through the right nostril for four counts.',
        'Repeat, alternating sides in a steady rhythm.',
      ],
      warningNote: 'Skip if you are congested or have a recent nasal injury.',
    ),
    'full_body_pmr': const ExerciseInfo(
      id: 'full_body_pmr',
      name: 'Full Body PMR',
      category: 'Relaxation',
      estimatedDuration: Duration(minutes: 20),
      icon: Icons.accessibility_new,
      color: Colors.green,
      howItWorks:
          'Progressive Muscle Relaxation moves from head to toe, tensing and releasing muscles so you learn the contrast between tension and ease.',
      benefits: <String>[
        'Releases physical tension thoroughly',
        'Improves body awareness',
        'Supports pain management',
        'Reduces tension headaches',
        'Improves sleep quality',
        'Helps with generalized anxiety',
      ],
      whenToUse:
          'Before bed, when experiencing muscle tension or pain, during stressful periods, or as a weekly relaxation ritual.',
      steps: <String>[
        'Lie down in a comfortable, quiet space.',
        'Start with your right hand: make a fist for five seconds.',
        'Notice the tension, then release for 10 seconds.',
        'Move through each muscle group head to toe.',
        'Contrast tension with relaxation each time.',
        'Finish with a full body awareness scan.',
      ],
    ),
    'quick_pmr': const ExerciseInfo(
      id: 'quick_pmr',
      name: 'Quick PMR (5 min)',
      category: 'Relaxation',
      estimatedDuration: Duration(minutes: 5),
      icon: Icons.flash_on,
      color: Colors.amber,
      howItWorks:
          'A condensed PMR sequence focusing on key muscle groups for rapid tension release.',
      benefits: <String>[
        'Delivers fast stress relief',
        'Portable relaxation technique',
        'Softens immediate tension',
        'Works at a desk or in the car',
        'Gentle entry into PMR practice',
      ],
      whenToUse:
          'During short breaks, before meetings, or whenever you feel tightness but only have a few minutes.',
      steps: <String>[
        'Sit comfortably with feet grounded.',
        'Tense hands and arms for five seconds, then relax.',
        'Tense face and jaw, then release.',
        'Tense shoulders and neck, then release.',
        'Tense chest and abdomen, then release.',
        'Tense legs and feet, then release.',
        'Notice overall relaxation in your body.',
      ],
    ),
    '5_4_3_2_1_sensory': const ExerciseInfo(
      id: '5_4_3_2_1_sensory',
      name: '5-4-3-2-1 Grounding',
      category: 'Grounding',
      estimatedDuration: Duration(minutes: 5),
      icon: Icons.sensors,
      color: Colors.indigo,
      howItWorks:
          'Sequentially naming sensations from each of the five senses anchors you to the present and interrupts anxious loops.',
      benefits: <String>[
        'Interrupts panic attacks',
        'Counters dissociation',
        'Brings focus to the present',
        'Rapidly reduces anxiety',
        'Requires no equipment',
        'Works in any environment',
      ],
      whenToUse:
          'During panic, flashbacks, overwhelming situations, or whenever anxiety is spiking quickly.',
      steps: <String>[
        'Name five things you can see.',
        'Name four things you can touch.',
        'Name three things you can hear.',
        'Name two things you can smell.',
        'Name one thing you can taste.',
        'Take slow breaths between each sense.',
        'Speak aloud if possible for added grounding.',
      ],
    ),
    'thought_challenging': const ExerciseInfo(
      id: 'thought_challenging',
      name: 'Thought Challenging',
      category: 'Cognitive',
      estimatedDuration: Duration(minutes: 10),
      icon: Icons.psychology,
      color: Colors.deepPurple,
      howItWorks:
          'A CBT staple that uncovers negative automatic thoughts, evaluates evidence, and reframes them into balanced statements.',
      benefits: <String>[
        'Weakens negative thinking patterns',
        'Improves rational evaluation',
        'Challenges cognitive distortions',
        'Builds emotional resilience',
        'Supports long-term mood change',
      ],
      whenToUse:
          'When stuck in negative loops, feeling intense emotions, or noticing distortions like catastrophizing.',
      steps: <String>[
        'Identify the automatic negative thought.',
        'List evidence supporting the thought.',
        'List evidence that contradicts it.',
        'Spot cognitive distortions involved.',
        'Write alternative perspectives.',
        'Create a balanced, realistic statement.',
        'Notice any shift in your mood or body.',
      ],
    ),
    'worry_time': const ExerciseInfo(
      id: 'worry_time',
      name: 'Worry Time Scheduling',
      category: 'Cognitive',
      estimatedDuration: Duration(minutes: 15),
      icon: Icons.schedule,
      color: Colors.red,
      howItWorks:
          'Assign a daily 15-minute block solely for worrying. Outside that time, postpone concerns to contain anxiety.',
      benefits: <String>[
        'Contains worry to a set window',
        'Reduces daily rumination',
        'Improves focus and productivity',
        'Builds anxiety management skills',
        'Creates a sense of control',
      ],
      whenToUse:
          'Same time each day (not bedtime). Ideal for chronic worriers or generalized anxiety that interrupts daily life.',
      steps: <String>[
        'Pick a consistent 15-minute slot.',
        'Set a timer and commit to full focus on worries.',
        'Write every worry that surfaces.',
        'Allow yourself to worry freely until the timer ends.',
        'Close your notes when time is up.',
        'Postpone new worries to the next session.',
        'Practice for two to three weeks for results.',
      ],
      warningNote:
          'Not a crisis tool. If you are in immediate danger, contact emergency services.',
    ),
    'cognitive_restructuring': const ExerciseInfo(
      id: 'cognitive_restructuring',
      name: 'Cognitive Restructuring',
      category: 'Cognitive',
      estimatedDuration: Duration(minutes: 12),
      icon: Icons.loop,
      color: Colors.deepOrangeAccent,
      howItWorks:
          'Identify automatic beliefs, examine evidence, and replace distortions with balanced, resilient thinking.',
      benefits: <String>[
        'Reframes core beliefs that fuel anxiety',
        'Builds flexible, compassionate thinking',
        'Reduces intensity of difficult emotions',
        'Strengthens problem-solving skills',
        'Supports long-term mood stability',
      ],
      whenToUse:
          'When you notice repeated negative narratives, during therapy homework, or before emotionally charged events.',
      steps: <String>[
        'Write down the triggering situation and automatic thought.',
        'List evidence that supports the thought.',
        'List evidence that challenges the thought.',
        'Spot cognitive distortions such as catastrophizing or mind reading.',
        'Draft a balanced replacement statement.',
        'Re-read the new statement until it feels believable.',
        'Notice any shift in your emotion or body.',
      ],
      warningNote:
          'If thoughts include self-harm, reach out to a licensed professional or crisis line.',
    ),
    'stream_consciousness': const ExerciseInfo(
      id: 'stream_consciousness',
      name: 'Stream of Consciousness',
      category: 'Journaling',
      estimatedDuration: Duration(minutes: 10),
      icon: Icons.edit_note,
      color: Colors.brown,
      howItWorks:
          'Continuous writing without stopping bypasses your inner editor and allows feelings and thoughts to surface.',
      benefits: <String>[
        'Clears mental clutter',
        'Processes complex emotions',
        'Boosts creativity',
        'Relieves overwhelm',
        'Improves self-awareness',
      ],
      whenToUse:
          'In the morning, when overwhelmed, stuck creatively, or needing emotional release.',
      steps: <String>[
        'Set a timer for five to ten minutes.',
        'Write without stopping or editing.',
        'Let thoughts flow freely onto the page.',
        'Keep your pen moving regardless of content.',
        'Ignore grammar and spelling.',
        'Choose whether to reread later or not at all.',
      ],
    ),
    'gratitude_journal': const ExerciseInfo(
      id: 'gratitude_journal',
      name: 'Gratitude Journal',
      category: 'Journaling',
      estimatedDuration: Duration(minutes: 5),
      icon: Icons.favorite,
      color: Colors.pink,
      howItWorks:
          'Writing specific moments of gratitude daily boosts mood, optimism, and resilience.',
      benefits: <String>[
        'Raises happiness and life satisfaction',
        'Supports physical health',
        'Increases empathy, decreases aggression',
        'Improves sleep quality',
        'Strengthens self-esteem',
        'Builds mental resilience',
      ],
      whenToUse:
          'Daily in the morning or evening, especially during difficult seasons to maintain perspective.',
      steps: <String>[
        'Choose a consistent time each day.',
        'Write three to five specific gratitudes.',
        'Focus on people and moments, not objects.',
        'Include why each item matters to you.',
        'Savor any positive emotions that arise.',
      ],
    ),
    'safe_place': const ExerciseInfo(
      id: 'safe_place',
      name: 'Safe Place Visualization',
      category: 'Visualization',
      estimatedDuration: Duration(minutes: 10),
      icon: Icons.home,
      color: Colors.cyan,
      howItWorks:
          'You create a vivid mental sanctuary using all senses, providing emotional refuge you can revisit anytime.',
      benefits: <String>[
        'Offers a psychological safe haven',
        'Reduces anxiety and stress',
        'Supports trauma processing',
        'Builds a sense of control',
        'Accessible wherever you are',
      ],
      whenToUse:
          'During anxiety, before or after therapy sessions, when feeling unsafe, or as a daily calming practice.',
      steps: <String>[
        'Close your eyes and take slow breaths.',
        'Imagine a place where you feel completely safe.',
        'Notice sights, colors, and textures.',
        'Tune into sounds and background noise.',
        'Notice scents or sensations in the air.',
        'Stay for five to ten minutes, returning anytime.',
      ],
    ),
    'success_visualization': const ExerciseInfo(
      id: 'success_visualization',
      name: 'Success Visualization',
      category: 'Visualization',
      estimatedDuration: Duration(minutes: 10),
      icon: Icons.emoji_events,
      color: Colors.yellow,
      howItWorks:
          'Mental rehearsal of achieving a goal primes your brain and body for real-world performance.',
      benefits: <String>[
        'Improves performance outcomes',
        'Boosts motivation and focus',
        'Builds confidence',
        'Reduces performance anxiety',
        'Clarifies goals and next steps',
      ],
      whenToUse:
          'Before presentations, interviews, competitions, or as part of goal-setting routines.',
      steps: <String>[
        'Select a specific goal or event.',
        'Relax your body and close your eyes.',
        'Visualize the moment of success in detail.',
        'Engage all senses throughout the scene.',
        'Feel the emotions of achieving the goal.',
        'Rehearse overcoming likely obstacles.',
        'Affirm your capability at the end.',
      ],
    ),
    'yoga_flow': const ExerciseInfo(
      id: 'yoga_flow',
      name: 'Gentle Yoga Flow',
      category: 'Movement',
      estimatedDuration: Duration(minutes: 15),
      icon: Icons.self_improvement,
      color: Colors.lightGreen,
      howItWorks:
          'A gentle sequence links mindful movement with breath to reduce tension and support flexibility.',
      benefits: <String>[
        'Releases stored tension',
        'Improves flexibility and mobility',
        'Enhances mind-body awareness',
        'Reduces stress hormones',
        'Elevates mood',
      ],
      whenToUse:
          'Morning energiser, midday reset, or evening wind-down. Modify poses for injuries.',
      steps: <String>[
        'Begin in Child’s Pose to settle.',
        'Flow through Cat-Cow for spinal mobility.',
        'Move into Downward Facing Dog.',
        'Transition into Warrior I for strength.',
        'Open into Triangle Pose for stretching.',
        'Fold forward while seated to release back.',
        'Finish in Corpse Pose for integration.',
      ],
      warningNote:
          'Consult a professional if you have injuries or mobility limitations.',
    ),
    'desk_stretches': const ExerciseInfo(
      id: 'desk_stretches',
      name: 'Desk Stretches',
      category: 'Movement',
      estimatedDuration: Duration(minutes: 3),
      icon: Icons.chair,
      color: Colors.blueGrey,
      howItWorks:
          'Quick stretches target the areas most affected by prolonged sitting to restore circulation and posture.',
      benefits: <String>[
        'Relieves neck and shoulder pain',
        'Supports better posture',
        'Increases energy and alertness',
        'Prevents repetitive strain',
        'Delivers fast stress relief',
      ],
      whenToUse:
          'Every hour during desk work, when stiffness strikes, or for an afternoon energy boost.',
      steps: <String>[
        'Roll your neck gently in each direction.',
        'Shrug and roll shoulders several times.',
        'Circle wrists and stretch forearms.',
        'Do a seated spinal twist.',
        'Fold forward while seated to stretch the back.',
        'Stand for gentle side stretches.',
        'Circle ankles before returning to work.',
      ],
    ),
    'tipp_skills': const ExerciseInfo(
      id: 'tipp_skills',
      name: 'TIPP Skills',
      category: 'Crisis',
      estimatedDuration: Duration(minutes: 5),
      icon: Icons.emergency,
      color: Colors.redAccent,
      howItWorks:
          'Temperature, Intense exercise, Paced breathing, and Paired muscle relaxation rapidly shift body chemistry during crises.',
      benefits: <String>[
        'Stops crises from escalating',
        'Changes body chemistry quickly',
        'Grounds you in physical sensation',
        'Prevents harmful impulses',
        'Evidence-based DBT skill',
      ],
      whenToUse:
          'Only during emotional crises rated 8/10 or higher, panic attacks, or moments of potential self-harm.',
      steps: <String>[
        'Temperature: apply cold water or ice.',
        'Intense exercise: 1-2 minutes of vigorous movement.',
        'Paced breathing: slow, deep breaths in cadence.',
        'Paired muscle relaxation: tense and release through the body.',
        'Continue until distress decreases, then switch to other skills.',
      ],
      warningNote:
          'If you feel unsafe or suicidal, contact emergency services immediately.',
    ),
    'stop_technique': const ExerciseInfo(
      id: 'stop_technique',
      name: 'STOP Technique',
      category: 'Crisis',
      estimatedDuration: Duration(minutes: 2),
      icon: Icons.back_hand,
      color: Colors.deepOrange,
      howItWorks:
          'A mindfulness micro-practice to interrupt automatic reactions and create space for wise choices.',
      benefits: <String>[
        'Interrupts impulsive reactions',
        'Prevents rash decisions',
        'Creates mindful pause',
        'Reduces emotional reactivity',
        'Easy to remember and apply',
      ],
      whenToUse:
          'When emotions surge, during conflicts, before decisions, or any time you notice escalation.',
      steps: <String>[
        'Stop whatever you are doing.',
        'Take a step back physically or mentally.',
        'Observe thoughts, feelings, and sensations.',
        'Observe the situation objectively.',
        'Proceed mindfully with the next helpful action.',
      ],
    ),
    'sleep_meditation': const ExerciseInfo(
      id: 'sleep_meditation',
      name: 'Sleep Meditation',
      category: 'Sleep',
      estimatedDuration: Duration(minutes: 20),
      icon: Icons.bedtime,
      color: Colors.indigo,
      howItWorks:
          'A guided blend of body scan, relaxation, and imagery designed to ease you into natural sleep.',
      benefits: <String>[
        'Helps you fall asleep faster',
        'Improves sleep quality',
        'Reduces nighttime anxiety',
        'Functions as a natural sleep aid',
        'Has no side effects',
      ],
      whenToUse:
          'Nightly before bed, during insomnia, or whenever the mind refuses to quiet.',
      steps: <String>[
        'Lie in bed with lights off.',
        'Breathe naturally as you settle.',
        'Scan your body from toes to head.',
        'Release tension as you progress.',
        'Visualize a peaceful, calming scene.',
        'Let thoughts drift without attachment.',
        'Allow yourself to sleep whenever it happens.',
      ],
      warningNote:
          'Consult a doctor if insomnia persists for more than two weeks.',
    ),
    'body_scan_sleep': const ExerciseInfo(
      id: 'body_scan_sleep',
      name: 'Body Scan for Sleep',
      category: 'Sleep',
      estimatedDuration: Duration(minutes: 15),
      icon: Icons.nightlight_round,
      color: Colors.indigoAccent,
      howItWorks:
          'Systematically releasing each muscle group while focusing on breath signals the body that it is safe to rest.',
      benefits: <String>[
        'Eases restlessness and nighttime tension',
        'Calms racing thoughts before bed',
        'Improves overall sleep quality',
        'Helps reset after stressful days',
        'Pairs well with evening mindfulness habits',
      ],
      whenToUse:
          'As part of your night routine, after late work sessions, or any time you wake in the middle of the night.',
      steps: <String>[
        'Lie comfortably on your back with lights dimmed.',
        'Breathe in slowly through the nose and exhale fully.',
        'Bring attention to your toes, gently tense then release.',
        'Move upward through legs, torso, arms, and face.',
        'Visualize tension melting out of each area.',
        'If thoughts drift, note them kindly and return to the body.',
        'Close with three slow breaths and allow sleep to come.',
      ],
    ),
    'emotion_wheel': const ExerciseInfo(
      id: 'emotion_wheel',
      name: 'Emotion Wheel Exercise',
      category: 'Emotional Regulation',
      estimatedDuration: Duration(minutes: 5),
      icon: Icons.colorize,
      color: Colors.purple,
      howItWorks:
          'Using an emotion wheel builds granularity by moving from core emotions to nuanced feelings.',
      benefits: <String>[
        'Expands emotional vocabulary',
        'Improves awareness and insight',
        'Helps process complex feelings',
        'Reduces overwhelm',
        'Strengthens communication skills',
      ],
      whenToUse:
          'When emotions feel unclear, before therapy, during journaling, or to build emotional intelligence.',
      steps: <String>[
        'Notice that you are feeling something.',
        'Start with a core emotion at the center of the wheel.',
        'Move outward to find a precise emotion.',
        'Name it without judgement.',
        'Consider what the emotion signals.',
        'Plan a wise, compassionate response.',
      ],
    ),
    'opposite_action': const ExerciseInfo(
      id: 'opposite_action',
      name: 'Opposite Action',
      category: 'Emotional Regulation',
      estimatedDuration: Duration(minutes: 8),
      icon: Icons.swap_horiz,
      color: Colors.purpleAccent,
      howItWorks:
          'Choose behaviors that oppose unhelpful urges to gradually shift emotions aligned with DBT skills.',
      benefits: <String>[
        'Breaks cycles of avoidance and withdrawal',
        'Builds confidence through values-based actions',
        'Reduces intensity of shame and anger',
        'Supports healthier relationship responses',
        'Encourages mindful decision-making',
      ],
      whenToUse:
          'When emotions are unjustified or overly intense, especially for sadness, anger, fear, or guilt.',
      steps: <String>[
        'Identify the emotion and the urge it generates.',
        'Check that acting opposite will not cause harm.',
        'Plan a specific, safe opposite action.',
        'Engage fully even if the urge remains.',
        'Pair actions with steady breathing and self-talk.',
        'Reflect afterward on changes in emotion intensity.',
      ],
    ),
    'butterfly_hug': const ExerciseInfo(
      id: 'butterfly_hug',
      name: 'Butterfly Hug',
      category: 'Quick Relief',
      estimatedDuration: Duration(minutes: 1),
      icon: Icons.favorite_border,
      color: Colors.lightBlue,
      howItWorks:
          'Crossed-arm tapping delivers bilateral stimulation similar to EMDR, calming the nervous system fast.',
      benefits: <String>[
        'Provides quick self-soothing',
        'Calms anxiety rapidly',
        'Discreet and equipment-free',
        'Evidence-backed through EMDR',
        'Useful in public spaces',
      ],
      whenToUse:
          'During anxiety spikes, before stressful events, or when you need quick comfort without external support.',
      steps: <String>[
        'Cross your arms over your chest.',
        'Place hands on opposite shoulders.',
        'Tap alternately left and right.',
        'Maintain a slow, gentle rhythm.',
        'Breathe steadily as you tap.',
        'Continue for 30-60 seconds and notice calm.',
      ],
    ),
    'hand_warming': const ExerciseInfo(
      id: 'hand_warming',
      name: 'Hand Warming',
      category: 'Quick Relief',
      estimatedDuration: Duration(minutes: 3),
      icon: Icons.thermostat,
      color: Colors.orange,
      howItWorks:
          'Focusing on warming your hands increases blood flow and triggers the parasympathetic response.',
      benefits: <String>[
        'Activates relaxation response',
        'Reduces anxiety symptoms',
        'Lowers blood pressure',
        'Improves focus and grounding',
        'Builds mind-body connection',
      ],
      whenToUse:
          'During anxious moments, before stressful events, when stressed-induced chill happens, or as biofeedback practice.',
      steps: <String>[
        'Sit with hands resting on your lap.',
        'Close your eyes and slow your breathing.',
        'Focus attention on the sensation in your hands.',
        'Imagine warmth flowing into your palms.',
        'Visualize sunlight or heat surrounding them.',
        'Notice tingling or temperature changes.',
        'Practice daily to strengthen the response.',
      ],
    ),
  };

  static ExerciseInfo? getExerciseInfo(String id) => _exercises[id];

  static List<ExerciseInfo> getAllExercises() => _exercises.values.toList();

  static List<ExerciseInfo> getExercisesByCategory(String category) =>
      _exercises.values
          .where((ExerciseInfo exercise) => exercise.category == category)
          .toList();
}
