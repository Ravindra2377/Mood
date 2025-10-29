import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/exercise_models.dart';
import '../../services/exercise_service.dart';
import '../../widgets/exercise_scaffold.dart';
import '../../widgets/breathing_circle.dart';
import '../../widgets/control_bar.dart';

class FourSevenEightScreen extends StatefulWidget {
  const FourSevenEightScreen({Key? key}) : super(key: key);

  @override
  _FourSevenEightScreenState createState() => _FourSevenEightScreenState();
}

class _FourSevenEightScreenState extends State<FourSevenEightScreen> {
  final pattern = BreathingPattern.fourSevenEight;
  late ExerciseSession session;

  int currentPhase = 0;
  int secondsRemaining = 4;
  bool isRunning = false;
  bool isPaused = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    session = ExerciseSession(
      exerciseId: '4_7_8_breathing',
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
      subtitle:
          'Inhale ${pattern.phaseDurations[0]}, Hold ${pattern.phaseDurations[1]}, Exhale ${pattern.phaseDurations[2]}',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Follow the pattern: ${pattern.phaseDurations[0]}s Inhale, ${pattern.phaseDurations[1]}s Hold, ${pattern.phaseDurations[2]}s Exhale.',
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
