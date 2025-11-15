import 'package:flutter/material.dart';

class ExerciseControlBar extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onStop;
  final bool isRunning;
  final bool isPaused;

  const ExerciseControlBar({
    super.key,
    required this.onStart,
    required this.onPause,
    required this.onStop,
    this.isRunning = false,
    this.isPaused = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (!isRunning || isPaused)
          ElevatedButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.play_arrow),
            label: Text(isPaused ? 'Resume' : 'Start'),
          ),
        if (isRunning && !isPaused)
          ElevatedButton.icon(
            onPressed: onPause,
            icon: const Icon(Icons.pause),
            label: const Text('Pause'),
          ),
        OutlinedButton.icon(
          onPressed: onStop,
          icon: const Icon(Icons.stop),
          label: const Text('Stop'),
        ),
      ],
    );
  }
}
