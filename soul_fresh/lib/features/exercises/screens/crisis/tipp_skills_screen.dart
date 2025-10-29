import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/exercise_models.dart';
import '../../services/exercise_service.dart';
import '../../widgets/control_bar.dart';
import '../../widgets/exercise_scaffold.dart';

class TippSkillsScreen extends StatefulWidget {
  static const route = '/tipp_skills';

  const TippSkillsScreen({super.key});

  @override
  State<TippSkillsScreen> createState() => _TippSkillsScreenState();
}

class _TippSkillsScreenState extends State<TippSkillsScreen> {
  late ExerciseSession session;
  final List<_TippStep> _steps = _buildSteps();

  int _currentIndex = 0;
  int _secondsRemaining = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    session = ExerciseSession(
      exerciseId: 'tipp_skills',
      startTime: DateTime.now(),
    );
    _secondsRemaining = _steps.first.durationSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsRemaining > 1) {
        setState(() => _secondsRemaining--);
      } else {
        _advanceStep();
      }
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = true;
    });
  }

  Future<void> _stop({bool completed = false}) async {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
    });

    session
      ..endTime = DateTime.now()
      ..extraData = {
        'steps_completed': _currentIndex + (completed ? 1 : 0),
        'completed': completed,
      };
    await ExerciseService().saveSession(session);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _advanceStep() {
    final bool isLast = _currentIndex == _steps.length - 1;
    if (isLast) {
      _stop(completed: true);
      return;
    }

    setState(() {
      _currentIndex++;
      _secondsRemaining = _steps[_currentIndex].durationSeconds;
    });
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentIndex];
    final progress = (_currentIndex + 1) / _steps.length;

    return ExerciseScaffold(
      title: 'TIPP Skills',
      subtitle: 'Rapid crisis cooling sequence',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Move through each step to reduce emotional intensity. Keep breath slow as you transition.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step ${_currentIndex + 1} of ${_steps.length}',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    step.title,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(step.description),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Duration: ${step.durationSeconds} seconds'),
              Text(
                '$_secondsRemaining s',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: progress.clamp(0, 1)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                ...step.tips.map(
                  (tip) => ListTile(
                    leading: const Icon(Icons.check_circle_outline),
                    title: Text(tip),
                  ),
                ),
              ],
            ),
          ),
          ExerciseControlBar(
            onStart: _start,
            onPause: _pause,
            onStop: () => _stop(),
            isRunning: _isRunning,
            isPaused: _isPaused,
          ),
        ],
      ),
    );
  }
}

class _TippStep {
  const _TippStep({
    required this.title,
    required this.description,
    required this.durationSeconds,
    required this.tips,
  });

  final String title;
  final String description;
  final int durationSeconds;
  final List<String> tips;
}

List<_TippStep> _buildSteps() {
  return const [
    _TippStep(
      title: 'Temperature Change',
      description:
          'Cool your face or neck with cold water or an ice pack to trigger the dive reflex.',
      durationSeconds: 30,
      tips: [
        'Hold your breath and splash cold water for a few seconds.',
        'Alternatively press a cold pack to your cheeks.',
      ],
    ),
    _TippStep(
      title: 'Intense Exercise',
      description:
          'Brief vigorous movement burns off adrenaline and resets the nervous system.',
      durationSeconds: 45,
      tips: [
        'Try jumping jacks, running in place, or fast push-ups.',
        'Keep breathing; stop if you feel dizzy.',
      ],
    ),
    _TippStep(
      title: 'Paced Breathing',
      description:
          'Inhale for four counts, exhale for six to lengthen the out-breath.',
      durationSeconds: 60,
      tips: [
        'Place a hand on your belly and feel it rise and fall.',
        'Keep shoulders relaxed and jaw unclenched.',
      ],
    ),
    _TippStep(
      title: 'Paired Muscle Relaxation',
      description:
          'Gently tense and release muscle groups to release residual tension.',
      durationSeconds: 60,
      tips: [
        'Start with hands and arms, then shoulders, then face.',
        'Use the release to notice warmth and heaviness.',
      ],
    ),
  ];
}
