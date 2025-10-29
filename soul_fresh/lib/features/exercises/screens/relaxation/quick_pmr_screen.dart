import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/exercise_models.dart';
import '../../services/exercise_service.dart';
import '../../widgets/control_bar.dart';
import '../../widgets/exercise_scaffold.dart';

class QuickPMRScreen extends StatefulWidget {
  const QuickPMRScreen({super.key});

  @override
  State<QuickPMRScreen> createState() => _QuickPMRScreenState();
}

class _QuickPMRScreenState extends State<QuickPMRScreen> {
  late ExerciseSession session;
  final List<_QuickGroup> _groups = _buildQuickGroups();

  int _currentIndex = 0;
  bool _isTensingPhase = true;
  int _secondsRemaining = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    session = ExerciseSession(
      exerciseId: 'quick_pmr',
      startTime: DateTime.now(),
    );
    _secondsRemaining = _groups.first.tenseSeconds;
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
        _advancePhase();
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

  Future<void> _stop() async {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
    });

    session
      ..endTime = DateTime.now()
      ..extraData = {
        'groups_completed': _currentIndex + 1,
      };
    await ExerciseService().saveSession(session);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _advancePhase() {
    final bool isLastGroup = _currentIndex == _groups.length - 1;
    setState(() {
      if (_isTensingPhase) {
        _isTensingPhase = false;
        _secondsRemaining = _groups[_currentIndex].relaxSeconds;
      } else if (isLastGroup) {
        _stop();
      } else {
        _isTensingPhase = true;
        _currentIndex++;
        _secondsRemaining = _groups[_currentIndex].tenseSeconds;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final group = _groups[_currentIndex];
    final double progress =
        (_currentIndex / _groups.length).clamp(0, 1).toDouble();

    return ExerciseScaffold(
      title: 'Quick PMR',
      subtitle: '5 minute reset',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cycle through these groups with a gentle 4-second tense / 6-second release rhythm. Keep breathing steadily throughout.',
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
                    _isTensingPhase ? 'Tense' : 'Release',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    group.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(group.tip),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Step ${_currentIndex + 1} of ${_groups.length}'),
              Text(
                '${_secondsRemaining}s remaining',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              Chip(label: Text('Breathe calmly')),
              Chip(label: Text('Notice the contrast')),
              Chip(label: Text('Loosen jaw and shoulders')),
            ],
          ),
          const Spacer(),
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

class _QuickGroup {
  const _QuickGroup({
    required this.name,
    required this.tenseSeconds,
    required this.relaxSeconds,
    required this.tip,
  });

  final String name;
  final int tenseSeconds;
  final int relaxSeconds;
  final String tip;
}

List<_QuickGroup> _buildQuickGroups() {
  return const [
    _QuickGroup(
      name: 'Hands & Forearms',
      tenseSeconds: 4,
      relaxSeconds: 6,
      tip:
          'Clench your fists and flex your forearms before releasing and shaking out the tension.',
    ),
    _QuickGroup(
      name: 'Shoulders & Neck',
      tenseSeconds: 4,
      relaxSeconds: 6,
      tip:
          'Lift your shoulders toward your ears, hold briefly, then drop them as you exhale.',
    ),
    _QuickGroup(
      name: 'Face & Jaw',
      tenseSeconds: 4,
      relaxSeconds: 6,
      tip:
          'Scrunch your face and press your tongue to the roof of your mouth, then soften your features.',
    ),
    _QuickGroup(
      name: 'Breath & Chest',
      tenseSeconds: 4,
      relaxSeconds: 6,
      tip:
          'Take a deep breath, expand your chest, hold, then exhale with a sigh letting your ribs relax.',
    ),
  ];
}
