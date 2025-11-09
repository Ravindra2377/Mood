import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../widgets/exercise_info_dialog.dart';

class ExercisesMainScreen extends StatefulWidget {
  static const String route = '/exercises';

  const ExercisesMainScreen({super.key});

  @override
  State<ExercisesMainScreen> createState() => _ExercisesMainScreenState();
}

class _ExercisesMainScreenState extends State<ExercisesMainScreen> {
  static const List<_FocusOption> _focusOptions = <_FocusOption>[
    _FocusOption(
      id: 'steady',
      label: 'Find calm',
      emoji: '😌',
      description: 'Steady anxious moments with paced breathing and grounding.',
    ),
    _FocusOption(
      id: 'energize',
      label: 'Boost energy',
      emoji: '⚡',
      description:
          'Refresh a tired mind with uplifting movement and focus resets.',
    ),
    _FocusOption(
      id: 'reset',
      label: 'Quick reset',
      emoji: '🌿',
      description:
          'Take a short pause to clear your head before the next task.',
    ),
  ];

  String _selectedFocusId = _focusOptions.first.id;

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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: _allExercises.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Column(
              children: [
                _buildFocusHeader(),
                const SizedBox(height: 20),
              ],
            );
          }

          final _ExerciseListItem item = _allExercises[index - 1];
          return Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(
                item.name,
                style: AppTypography.body1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text('Tap to learn how this exercise helps'),
              trailing: const Icon(Icons.info_outline),
              onTap: () {
                showExerciseInfoDialog(
                  context,
                  exerciseId: item.id,
                  onStartExercise: () {
                    Navigator.of(context).pushNamed(item.route);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFocusHeader() {
    final _FocusOption activeFocus =
        _focusOptions.firstWhere((option) => option.id == _selectedFocusId);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.secondaryPastel.withOpacity(0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryPastel.withOpacity(0.2),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Guided exercises for any moment',
            style: AppTypography.h4.copyWith(
              color: AppColors.charcoal,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            activeFocus.description,
            style: AppTypography.body1.copyWith(
              color: AppColors.charcoal.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: [
              for (final _FocusOption option in _focusOptions)
                ChoiceChip(
                  avatar: Text(option.emoji),
                  label: Text(option.label),
                  selected: option.id == _selectedFocusId,
                  onSelected: (bool selected) {
                    if (selected) {
                      _updateFocus(option.id);
                    }
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _updateFocus(String id) {
    if (id == _selectedFocusId) {
      return;
    }
    setState(() {
      _selectedFocusId = id;
    });
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

class _FocusOption {
  const _FocusOption({
    required this.id,
    required this.label,
    required this.emoji,
    required this.description,
  });

  final String id;
  final String label;
  final String emoji;
  final String description;
}

