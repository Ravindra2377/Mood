import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/exercise_models.dart';
import '../../services/exercise_service.dart';
import '../../widgets/control_bar.dart';
import '../../widgets/exercise_scaffold.dart';

class SleepMeditationScreen extends StatefulWidget {
  static const route = '/sleep_meditation';

  const SleepMeditationScreen({super.key});
  @override
  State<SleepMeditationScreen> createState() => _SleepMeditationScreenState();
}

class _SleepMeditationScreenState extends State<SleepMeditationScreen> {
  late ExerciseSession session;
  int total = 300; // 5 min wind-down
  int remaining = 300;
  bool running = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    session = ExerciseSession(
      exerciseId: 'sleep_meditation',
      startTime: DateTime.now(),
    );
  }

  void _start() {
    setState(() => running = true);
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remaining > 0) {
        setState(() => remaining--);
      } else {
        _stop();
      }
    });
  }

  void _stop() async {
    timer?.cancel();
    session.endTime = DateTime.now();
    await ExerciseService().saveSession(session);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mins = (remaining ~/ 60).toString().padLeft(2, '0');
    final secs = (remaining % 60).toString().padLeft(2, '0');
    return ExerciseScaffold(
      title: 'Sleep Meditation',
      subtitle: '5-Minute Wind-down',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$mins:$secs', style: Theme.of(context).textTheme.displayLarge),
          ExerciseControlBar(
            onStart: _start,
            onPause: () => timer?.cancel(),
            onStop: _stop,
            isRunning: running,
          ),
        ],
      ),
    );
  }
}
