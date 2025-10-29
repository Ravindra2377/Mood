import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/exercise_models.dart';
import '../../services/exercise_service.dart';
import '../../widgets/control_bar.dart';
import '../../widgets/exercise_scaffold.dart';

class DeskStretchesScreen extends StatefulWidget {
  static const route = '/desk_stretches';

  const DeskStretchesScreen({super.key});

  @override
  State<DeskStretchesScreen> createState() => _DeskStretchesScreenState();
}

class _DeskStretchesScreenState extends State<DeskStretchesScreen> {
  late ExerciseSession session;
  final List<_Stretch> _stretches = _buildSequence();

  int _currentIndex = 0;
  int _secondsRemaining = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  Timer? _timer;
  final List<Map<String, dynamic>> _completed = [];

  @override
  void initState() {
    super.initState();
    session = ExerciseSession(
      exerciseId: 'desk_stretches',
      startTime: DateTime.now(),
    );
    _resetTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _resetTimer() {
    _secondsRemaining = _stretches[_currentIndex].durationSeconds;
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
        _completeStretch();
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
        'completed_stretches': _completed,
        'sequence_completed': completed,
      };

    await ExerciseService().saveSession(session);

    if (!mounted) {
      return;
    }
    Navigator.pop(context);
  }

  void _completeStretch() {
    _recordStretch();
    if (_currentIndex < _stretches.length - 1) {
      setState(() {
        _currentIndex++;
        _resetTimer();
      });
    } else {
      _stop(completed: true);
    }
  }

  void _skip() {
    _recordStretch(skipped: true);
    if (_currentIndex < _stretches.length - 1) {
      setState(() {
        _currentIndex++;
        _resetTimer();
      });
    } else {
      _stop(completed: true);
    }
  }

  void _recordStretch({bool skipped = false}) {
    final stretch = _stretches[_currentIndex];
    _completed.add({
      'stretch': stretch.title,
      'duration': stretch.durationSeconds,
      'skipped': skipped,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  String _formatTime(int seconds) {
    return seconds.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    final stretch = _stretches[_currentIndex];
    return ExerciseScaffold(
      title: 'Desk Stretches',
      subtitle: stretch.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _stretches.length,
          ),
          const SizedBox(height: 16),
          Text(
            'Stretch ${_currentIndex + 1} of ${_stretches.length}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surfaceVariant,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stretch.instructions,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: stretch.cues
                        .map((cue) => Chip(label: Text(cue)))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hold for',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_formatTime(_secondsRemaining)} s',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Focus on',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          stretch.focus,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _skip,
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Skip this stretch'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _stop(),
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: const Text('Finish early'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ExerciseControlBar(
            onStart: _start,
            onPause: _pause,
            onStop: _stop,
            isRunning: _isRunning,
            isPaused: _isPaused,
          ),
        ],
      ),
    );
  }
}

class _Stretch {
  _Stretch({
    required this.title,
    required this.instructions,
    required this.focus,
    required this.durationSeconds,
    required this.cues,
  });

  final String title;
  final String instructions;
  final String focus;
  final int durationSeconds;
  final List<String> cues;
}

List<_Stretch> _buildSequence() {
  return [
    _Stretch(
      title: 'Neck tilt with breath',
      instructions:
          'Sit tall. Drop right ear toward shoulder and gently guide with right hand. Breathe deeply and switch sides halfway.',
      focus: 'Neck release',
      durationSeconds: 30,
      cues: [
        'Keep shoulders relaxed',
        'Inhale length, exhale soften',
        'Switch at 15 seconds'
      ],
    ),
    _Stretch(
      title: 'Shoulder rolls',
      instructions:
          'Roll shoulders up toward ears, back, and down in slow circles. After 15 seconds, reverse direction.',
      focus: 'Upper back mobility',
      durationSeconds: 30,
      cues: [
        'Smooth circles',
        'Move with breath',
        'Feel shoulder blades glide'
      ],
    ),
    _Stretch(
      title: 'Seated spinal twist',
      instructions:
          'Plant feet hip-width apart. Inhale tall, exhale twist to the right, holding chair back. Stay for half the timer then switch.',
      focus: 'Spine rotation',
      durationSeconds: 40,
      cues: ['Sit tall', 'Twist from mid-spine', 'Keep breath steady'],
    ),
    _Stretch(
      title: 'Chest opener',
      instructions:
          'Interlace fingers behind back or grab chair, open chest by lifting sternum. Option to look upward slightly.',
      focus: 'Posture reset',
      durationSeconds: 40,
      cues: ['Broaden collarbones', 'Soften jaw', 'Keep ribs knit'],
    ),
    _Stretch(
      title: 'Wrist and forearm release',
      instructions:
          'Extend right arm, palm up. Gently pull fingers down with left hand. Switch after 20 seconds, then make slow circles.',
      focus: 'Forearm relief',
      durationSeconds: 40,
      cues: ['Elbow straight', 'Gentle pull', 'Finish with circles'],
    ),
    _Stretch(
      title: 'Seated hamstring fold',
      instructions:
          'Extend right leg, heel on floor. Hinge forward from hips with long spine. Switch sides after 20 seconds.',
      focus: 'Hamstring lengthening',
      durationSeconds: 40,
      cues: ['Keep spine long', 'Flex toes toward you', 'Avoid rounding back'],
    ),
    _Stretch(
      title: 'Final breath reset',
      instructions:
          'Sit back, place hands on belly and chest. Take five slow breaths, lengthening exhale to settle nervous system.',
      focus: 'Nervous system downshift',
      durationSeconds: 30,
      cues: ['Inhale for 4', 'Exhale for 6', 'Relax shoulders'],
    ),
  ];
}
