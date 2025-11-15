import 'package:flutter/material.dart';
import '../models/exercise_models.dart';

/// A circular animated indicator for breathing phases.
class BreathingCircle extends StatelessWidget {
  final BreathingPhase phase;
  final int seconds;
  final double size;

  const BreathingCircle({
    super.key,
    required this.phase,
    required this.seconds,
    this.size = 200.0,
  });

  Color _getPhaseColor() {
    switch (phase) {
      case BreathingPhase.inhale:
        return Colors.blue;
      case BreathingPhase.hold:
      case BreathingPhase.holdTwo:
        return Colors.green;
      case BreathingPhase.exhale:
        return Colors.orange;
    }
  }

  String _getPhaseText() {
    switch (phase) {
      case BreathingPhase.inhale:
        return 'Inhale';
      case BreathingPhase.hold:
      case BreathingPhase.holdTwo:
        return 'Hold';
      case BreathingPhase.exhale:
        return 'Exhale';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getPhaseColor();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: Duration(seconds: seconds),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.3),
            border: Border.all(color: color, width: 4),
          ),
          child: Center(
            child: Text(
              _getPhaseText(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '$seconds',
          style: Theme.of(context)
              .textTheme
              .displayLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          'seconds',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

