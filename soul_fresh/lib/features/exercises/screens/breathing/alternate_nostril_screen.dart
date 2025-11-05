import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/exercise_models.dart';
import '../../services/exercise_service.dart';
import '../../widgets/control_bar.dart';
import '../../widgets/exercise_scaffold.dart';

class AlternateNostrilScreen extends StatefulWidget {
  const AlternateNostrilScreen({super.key});

  @override
  State<AlternateNostrilScreen> createState() => _AlternateNostrilScreenState();
}

class _AlternateNostrilScreenState extends State<AlternateNostrilScreen> {
  late ExerciseSession session;
  final List<_BreathPhase> _phases = _buildPhases();

  int _currentIndex = 0;
  int _secondsRemaining = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  Timer? _timer;
  int _cyclesCompleted = 0;

  @override
  void initState() {
    super.initState();
    session = ExerciseSession(
      exerciseId: 'alternate_nostril_breathing',
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
    _secondsRemaining = _phases[_currentIndex].durationSeconds;
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

  Future<void> _stop({bool completed = false}) async {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
    });

    session
      ..endTime = DateTime.now()
      ..extraData = {
        'cycles_completed': _cyclesCompleted,
        'completed': completed,
      };
    await ExerciseService().saveSession(session);

    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  void _advancePhase() {
    final bool isLastPhase = _currentIndex == _phases.length - 1;
    setState(() {
      if (isLastPhase) {
        _cyclesCompleted++;
        _currentIndex = 0;
      } else {
        _currentIndex++;
      }
      _secondsRemaining = _phases[_currentIndex].durationSeconds;
    });
  }

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final phase = _phases[_currentIndex];
    return ExerciseScaffold(
      title: 'Alternate Nostril Breathing',
      subtitle: 'Nadi Shodhana (4-4-4 cycle)',
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
                    'Current phase',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    phase.title,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    phase.instructions,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text('Close right nostril with thumb')),
              Chip(label: Text('Alternate nostrils each phase')),
              Chip(label: Text('Keep breath smooth')),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(_secondsRemaining),
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cycles completed: $_cyclesCompleted',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
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

class _BreathPhase {
  const _BreathPhase({
    required this.title,
    required this.durationSeconds,
    required this.instructions,
  });

  final String title;
  final int durationSeconds;
  final String instructions;
}

List<_BreathPhase> _buildPhases() {
  return const [
    _BreathPhase(
      title: 'Inhale left nostril',
      durationSeconds: 4,
      instructions:
          'Close your right nostril and draw breath slowly through the left.',
    ),
    _BreathPhase(
      title: 'Hold gently',
      durationSeconds: 4,
      instructions:
          'Close both nostrils and hold the breath with relaxed shoulders.',
    ),
    _BreathPhase(
      title: 'Exhale right nostril',
      durationSeconds: 4,
      instructions: 'Open the right nostril and release the breath smoothly.',
    ),
    _BreathPhase(
      title: 'Inhale right nostril',
      durationSeconds: 4,
      instructions:
          'Keep the left nostril sealed and breathe in steadily through the right.',
    ),
    _BreathPhase(
      title: 'Hold gently',
      durationSeconds: 4,
      instructions: 'Pause to notice calm before switching sides.',
    ),
    _BreathPhase(
      title: 'Exhale left nostril',
      durationSeconds: 4,
      instructions:
          'Open the left nostril and exhale steadily to complete the cycle.',
    ),
  ];
}
