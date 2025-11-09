import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/exercise_models.dart';
import '../../services/exercise_service.dart';
import '../../widgets/control_bar.dart';
import '../../widgets/exercise_scaffold.dart';

class FullBodyPMRScreen extends StatefulWidget {
  const FullBodyPMRScreen({super.key});

  @override
  State<FullBodyPMRScreen> createState() => _FullBodyPMRScreenState();
}

class _FullBodyPMRScreenState extends State<FullBodyPMRScreen> {
  late ExerciseSession session;
  final List<_MuscleGroup> _groups = _buildGroups();

  int _currentGroupIndex = 0;
  bool _isTensingPhase = true;
  int _secondsRemaining = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    session = ExerciseSession(
      exerciseId: 'full_body_pmr',
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
        'groups_completed': _currentGroupIndex + 1,
        'completed':
            _currentGroupIndex == _groups.length - 1 && !_isTensingPhase,
      };
    await ExerciseService().saveSession(session);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _advancePhase() {
    final bool isLastGroup = _currentGroupIndex == _groups.length - 1;
    setState(() {
      if (_isTensingPhase) {
        _isTensingPhase = false;
        _secondsRemaining = _groups[_currentGroupIndex].relaxSeconds;
      } else if (isLastGroup) {
        _stop();
      } else {
        _isTensingPhase = true;
        _currentGroupIndex++;
        _secondsRemaining = _groups[_currentGroupIndex].tenseSeconds;
      }
    });
  }

  String _phaseLabel() => _isTensingPhase ? 'Tense' : 'Release';

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final group = _groups[_currentGroupIndex];
    final double completed =
        (_currentGroupIndex / _groups.length).clamp(0, 1).toDouble();

    return ExerciseScaffold(
      title: 'Full Body PMR',
      subtitle: 'Progressive Muscle Relaxation',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current muscle group',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    group.name,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    group.tip,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phase: ${_phaseLabel()}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text('Next up: ${group.nextPhaseLabel(_isTensingPhase)}'),
                  ],
                ),
              ),
              Text(
                _formatTime(_secondsRemaining),
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: completed),
          const SizedBox(height: 16),
          Text(
            'Upcoming groups',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _groups.length,
              itemBuilder: (context, index) {
                final item = _groups[index];
                final bool isActive = index == _currentGroupIndex;
                return ListTile(
                  leading: Icon(
                    isActive
                        ? Icons.self_improvement
                        : Icons.radio_button_unchecked,
                  ),
                  title: Text(item.name),
                  subtitle: Text(
                    '${item.tenseSeconds}s tense • ${item.relaxSeconds}s relax',
                  ),
                  trailing: isActive ? Chip(label: Text(_phaseLabel())) : null,
                );
              },
            ),
          ),
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

class _MuscleGroup {
  const _MuscleGroup({
    required this.name,
    required this.tenseSeconds,
    required this.relaxSeconds,
    required this.tip,
  });

  final String name;
  final int tenseSeconds;
  final int relaxSeconds;
  final String tip;

  String nextPhaseLabel(bool isTensingPhase) {
    if (isTensingPhase) {
      return 'Release for $relaxSeconds seconds';
    }
    return 'Prepare to tense $name for $tenseSeconds seconds';
  }
}

List<_MuscleGroup> _buildGroups() {
  return const [
    _MuscleGroup(
      name: 'Feet & Calves',
      tenseSeconds: 5,
      relaxSeconds: 7,
      tip:
          'Curl your toes and tense your calves. Notice the sensation before releasing.',
    ),
    _MuscleGroup(
      name: 'Thighs & Glutes',
      tenseSeconds: 5,
      relaxSeconds: 7,
      tip:
          'Press your knees together and squeeze your glutes while keeping shoulders relaxed.',
    ),
    _MuscleGroup(
      name: 'Stomach & Lower Back',
      tenseSeconds: 5,
      relaxSeconds: 7,
      tip:
          'Draw your belly button toward your spine, then let your abdomen soften completely.',
    ),
    _MuscleGroup(
      name: 'Chest & Shoulders',
      tenseSeconds: 5,
      relaxSeconds: 7,
      tip:
          'Take a deep breath, hold, and gently squeeze your shoulder blades together.',
    ),
    _MuscleGroup(
      name: 'Hands & Arms',
      tenseSeconds: 5,
      relaxSeconds: 7,
      tip:
          'Make tight fists and flex your biceps, then shake out your hands as you release.',
    ),
    _MuscleGroup(
      name: 'Neck & Jaw',
      tenseSeconds: 5,
      relaxSeconds: 7,
      tip:
          'Gently press your tongue to the roof of your mouth and tilt your head back slightly.',
    ),
    _MuscleGroup(
      name: 'Forehead & Eyes',
      tenseSeconds: 5,
      relaxSeconds: 7,
      tip:
          'Raise your eyebrows and close your eyes tightly, then smooth out your forehead.',
    ),
  ];
}
