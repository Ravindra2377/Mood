import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/exercise_models.dart';
import '../../services/exercise_service.dart';
import '../../widgets/exercise_scaffold.dart';
import '../../widgets/breathing_circle.dart';
import '../../widgets/control_bar.dart';

class ResonantBreathingScreen extends StatefulWidget {
  const ResonantBreathingScreen({Key? key}) : super(key: key);

  @override
  _ResonantBreathingScreenState createState() =>
      _ResonantBreathingScreenState();
}

class _ResonantBreathingScreenState extends State<ResonantBreathingScreen> {
  final pattern = BreathingPattern.resonant;
  late ExerciseSession session;

  int currentPhase = 0;
  int secondsRemaining = 5;
  bool isRunning = false;
  bool isPaused = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    session = ExerciseSession(
      exerciseId: 'resonant_breathing',
      startTime: DateTime.now(),
    );
  }

  void _start() {
    setState(() {
      isRunning = true;
      isPaused = false;
    });
    _runStep();
  }

  void _pause() {
    timer?.cancel();
    setState(() {
      isPaused = true;
      isRunning = false;
    });
  }

  void _stop() async {
    timer?.cancel();
    session.endTime = DateTime.now();
    await ExerciseService().saveSession(session);
    if (mounted) Navigator.pop(context);
  }

  void _runStep() {
    setState(() {
      secondsRemaining = pattern.phaseDurations[currentPhase];
    });
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (secondsRemaining > 1) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        timer?.cancel();
        currentPhase = (currentPhase + 1) % pattern.phases.length;
        if (mounted) _start();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExerciseScaffold(
      title: pattern.name,
      subtitle: '5-5 Pattern (6 breaths/min)',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Breathe in for ${pattern.phaseDurations[0]}s and out for ${pattern.phaseDurations[1]}s to balance your system.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: Center(
              child: BreathingCircle(
                phase: pattern.phases[currentPhase],
                seconds: secondsRemaining,
              ),
            ),
          ),
          ExerciseControlBar(
            onStart: _start,
            onPause: _pause,
            onStop: _stop,
            isRunning: isRunning,
            isPaused: isPaused,
          ),
        ],
      ),
    );
  }
}
