import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/exercise_models.dart';
import '../../services/exercise_service.dart';
import '../../widgets/control_bar.dart';
import '../../widgets/exercise_scaffold.dart';

class YogaFlowScreen extends StatefulWidget {
  const YogaFlowScreen({super.key});

  @override
  State<YogaFlowScreen> createState() => _YogaFlowScreenState();
}

class _YogaFlowScreenState extends State<YogaFlowScreen> {
  late ExerciseSession session;
  final List<_YogaPose> _poses = _buildFlow();

  int _currentIndex = 0;
  int _secondsRemaining = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  Timer? _timer;
  final List<Map<String, dynamic>> _completedPoses = [];

  @override
  void initState() {
    super.initState();
    session = ExerciseSession(
      exerciseId: 'gentle_yoga',
      startTime: DateTime.now(),
    );
    _resetTimerForCurrentPose();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _resetTimerForCurrentPose() {
    _secondsRemaining = _poses[_currentIndex].durationSeconds;
  }

  void _startFlow() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsRemaining > 1) {
        setState(() => _secondsRemaining--);
      } else {
        _completeCurrentPose();
      }
    });
  }

  void _pauseFlow() {
    _timer?.cancel();
    setState(() {
      _isPaused = true;
      _isRunning = false;
    });
  }

  Future<void> _stopFlow({bool completed = false}) async {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
    });

    session
      ..endTime = DateTime.now()
      ..extraData = {
        'completed_poses': _completedPoses,
        'flow_completed': completed,
      };

    await ExerciseService().saveSession(session);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          completed
              ? 'Flow complete. Take a deep breath before moving on.'
              : 'Session saved. Come back when you\'re ready.',
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  void _completeCurrentPose() {
    _recordPoseCompletion();
    if (_currentIndex < _poses.length - 1) {
      setState(() {
        _currentIndex++;
        _resetTimerForCurrentPose();
      });
    } else {
      _stopFlow(completed: true);
    }
  }

  void _skipPose() {
    _recordPoseCompletion(skipped: true);
    if (_currentIndex < _poses.length - 1) {
      setState(() {
        _currentIndex++;
        _resetTimerForCurrentPose();
      });
    } else {
      _stopFlow(completed: true);
    }
  }

  void _recordPoseCompletion({bool skipped = false}) {
    final pose = _poses[_currentIndex];
    _completedPoses.add({
      'pose': pose.name,
      'duration': pose.durationSeconds,
      'skipped': skipped,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final pose = _poses[_currentIndex];
    return ExerciseScaffold(
      title: 'Gentle Yoga Flow',
      subtitle: 'Grounded movement, 15 minutes',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _poses.length,
          ),
          const SizedBox(height: 16),
          Text(
            'Pose ${_currentIndex + 1} of ${_poses.length}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            pose.name,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Chip(
                avatar: const Icon(Icons.timer, size: 18),
                label: Text('${pose.durationSeconds ~/ 60} min'),
              ),
              const SizedBox(width: 8),
              Chip(
                avatar: const Icon(Icons.self_improvement, size: 18),
                label: Text(pose.focus),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        pose.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Cues',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: pose.cues
                        .map(
                          (cue) => Chip(
                            label: Text(cue),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Timer',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(_secondsRemaining),
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _skipPose,
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Skip pose'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _stopFlow(),
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: const Text('Finish early'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ExerciseControlBar(
            onStart: _startFlow,
            onPause: _pauseFlow,
            onStop: _stopFlow,
            isRunning: _isRunning,
            isPaused: _isPaused,
          ),
        ],
      ),
    );
  }
}

class _YogaPose {
  _YogaPose({
    required this.name,
    required this.description,
    required this.focus,
    required this.durationSeconds,
    required this.cues,
  });

  final String name;
  final String description;
  final String focus;
  final int durationSeconds;
  final List<String> cues;
}

List<_YogaPose> _buildFlow() {
  return [
    _YogaPose(
      name: 'Grounding breath in child\'s pose',
      description:
          'Begin kneeling, sink hips toward heels, forehead to mat. Arms stretch forward or rest beside legs. Soften shoulders and breathe into your back body.',
      focus: 'Centering',
      durationSeconds: 120,
      cues: ['Hips heavy', 'Forehead relaxed', 'Slow nasal breath'],
    ),
    _YogaPose(
      name: 'Cat-Cow spinal waves',
      description:
          'Transition to tabletop. Alternate between arching and rounding your spine, syncing movement with breath for gentle articulation.',
      focus: 'Spine mobility',
      durationSeconds: 120,
      cues: ['Press palms down', 'Tailbone leads', 'Move with breath'],
    ),
    _YogaPose(
      name: 'Downward facing dog',
      description:
          'Lift hips up and back. Pedal through knees to warm hamstrings. Feel length from wrists through hips.',
      focus: 'Full body stretch',
      durationSeconds: 120,
      cues: ['Soft knees', 'Lengthen spine', 'Relax head'],
    ),
    _YogaPose(
      name: 'Low lunge sequence',
      description:
          'Step right foot forward, left knee down. Sweep arms up, open chest. Option to add gentle twist. Repeat on left side.',
      focus: 'Hip opening',
      durationSeconds: 240,
      cues: ['Front knee over ankle', 'Hips square', 'Lift through crown'],
    ),
    _YogaPose(
      name: 'Seated twist',
      description:
          'Sit cross-legged. Inhale length, exhale twist to the right, placing left hand on knee. Stay for a few breaths then switch sides.',
      focus: 'Detox & release',
      durationSeconds: 180,
      cues: ['Inhale length', 'Exhale twist', 'Relax shoulders'],
    ),
    _YogaPose(
      name: 'Supine figure four',
      description:
          'Lie down. Cross right ankle over left thigh, thread hands behind hamstring. Gently draw legs toward you. Switch sides.',
      focus: 'Glute release',
      durationSeconds: 180,
      cues: ['Flex foot', 'Relax neck', 'Breathe into hips'],
    ),
    _YogaPose(
      name: 'Final rest (Savasana)',
      description:
          'Extend legs long, arms by sides, palms face up. Soften jaw and return to a steady breath, sealing in the practice.',
      focus: 'Integration',
      durationSeconds: 240,
      cues: ['Heavy limbs', 'Soften breath', 'Release effort'],
    ),
  ];
}
