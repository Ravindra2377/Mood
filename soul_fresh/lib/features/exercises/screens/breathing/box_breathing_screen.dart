import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/exercise_models.dart';
import '../../services/exercise_service.dart';
import '../../widgets/breathing_circle.dart';
import '../../widgets/control_bar.dart';
import '../../widgets/exercise_scaffold.dart';

class BoxBreathingScreen extends StatefulWidget {
  const BoxBreathingScreen({super.key});

  @override
  _BoxBreathingScreenState createState() => _BoxBreathingScreenState();
}

class _BoxBreathingScreenState extends State<BoxBreathingScreen> {
  final pattern = BreathingPattern.boxBreathing;
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
      exerciseId: 'box_breathing',
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
      subtitle: '${pattern.phaseDurations.join('-')} Pattern',
      child: Column(
        children: [
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
