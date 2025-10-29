import 'package:flutter/material.dart';

import '../widgets/exercise_info_dialog.dart';

class ExercisesMainScreen extends StatelessWidget {
  static const String route = '/exercises';

  const ExercisesMainScreen({super.key});

  final List<_ExerciseListItem> _allExercises = const <_ExerciseListItem>[
    _ExerciseListItem(
      id: 'box_breathing',
      name: 'Box Breathing',
      route: '/exercises/box-breathing',
    ),
    _ExerciseListItem(
      id: '4_7_8_breathing',
      name: '4-7-8 Breathing',
      route: '/exercises/4-7-8-breathing',
    ),
    _ExerciseListItem(
      id: 'resonant_breathing',
      name: 'Resonant Breathing',
      route: '/exercises/resonant-breathing',
    ),
    _ExerciseListItem(
      id: 'alternate_nostril',
      name: 'Alternate Nostril Breathing',
      route: '/exercises/alternate-nostril',
    ),
    _ExerciseListItem(
      id: 'full_body_pmr',
      name: 'Full Body PMR',
      route: '/exercises/full-body-pmr',
    ),
    _ExerciseListItem(
      id: 'quick_pmr',
      name: 'Quick PMR',
      route: '/exercises/quick-pmr',
    ),
    _ExerciseListItem(
      id: '5_4_3_2_1_sensory',
      name: '5-4-3-2-1 Grounding',
      route: '/exercises/5-4-3-2-1-grounding',
    ),
    _ExerciseListItem(
      id: 'thought_challenging',
      name: 'Thought Challenging',
      route: '/exercises/thought-challenging',
    ),
    _ExerciseListItem(
      id: 'worry_time',
      name: 'Worry Time Scheduling',
      route: '/exercises/worry-time',
    ),
    _ExerciseListItem(
      id: 'stream_consciousness',
      name: 'Stream of Consciousness',
      route: '/exercises/stream-consciousness',
    ),
    _ExerciseListItem(
      id: 'gratitude_journal',
      name: 'Gratitude Journal',
      route: '/exercises/gratitude-journal',
    ),
    _ExerciseListItem(
      id: 'safe_place',
      name: 'Safe Place Visualization',
      route: '/exercises/safe-place',
    ),
    _ExerciseListItem(
      id: 'success_visualization',
      name: 'Success Visualization',
      route: '/exercises/success-visualization',
    ),
    _ExerciseListItem(
      id: 'yoga_flow',
      name: 'Gentle Yoga Flow',
      route: '/exercises/yoga-flow',
    ),
    _ExerciseListItem(
      id: 'desk_stretches',
      name: 'Desk Stretches',
      route: '/exercises/desk-stretches',
    ),
    _ExerciseListItem(
      id: 'tipp_skills',
      name: 'TIPP Skills (Crisis)',
      route: '/exercises/tipp-skills',
    ),
    _ExerciseListItem(
      id: 'stop_technique',
      name: 'STOP Technique',
      route: '/exercises/stop-technique',
    ),
    _ExerciseListItem(
      id: 'sleep_meditation',
      name: 'Sleep Meditation',
      route: '/exercises/sleep-meditation',
    ),
    _ExerciseListItem(
      id: 'emotion_wheel',
      name: 'Emotion Wheel Exercise',
      route: '/exercises/emotion-wheel',
    ),
    _ExerciseListItem(
      id: 'butterfly_hug',
      name: 'Butterfly Hug',
      route: '/exercises/butterfly-hug',
    ),
    _ExerciseListItem(
      id: 'hand_warming',
      name: 'Hand Warming',
      route: '/exercises/hand-warming',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Exercises')),
      body: ListView.builder(
        itemCount: _allExercises.length,
        itemBuilder: (BuildContext context, int index) {
          final _ExerciseListItem item = _allExercises[index];
          return ListTile(
            title: Text(item.name),
            subtitle: const Text('Tap to learn how this exercise helps'),
            trailing: const Icon(Icons.info_outline),
            onTap: () => showExerciseInfoDialog(
              context,
              exerciseId: item.id,
              onStartExercise: () =>
                  Navigator.of(context).pushNamed(item.route),
            ),
          );
        },
      ),
    );
  }
}

class _ExerciseListItem {
  const _ExerciseListItem({
    required this.id,
    required this.name,
    required this.route,
  });

  final String id;
  final String name;
  final String route;
}
