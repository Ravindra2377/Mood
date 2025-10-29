import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/exercise_models.dart';
import '../../services/exercise_service.dart';
import '../../widgets/control_bar.dart';
import '../../widgets/exercise_scaffold.dart';

class HandWarmingScreen extends StatefulWidget {
  const HandWarmingScreen({Key? key}) : super(key: key);

  @override
  State<HandWarmingScreen> createState() => _HandWarmingScreenState();
}

class _HandWarmingScreenState extends State<HandWarmingScreen> {
  static const int _totalSeconds = 180;

  late ExerciseSession session;
  Timer? _timer;
  int _secondsRemaining = _totalSeconds;
  bool _isRunning = false;
  bool _isPaused = false;
  double _warmthLevel = 0.3;
  int _moodBefore = 5;
  int? _moodAfter;

  final List<String> _visuals = const [
    'Golden sunlight pooling into both palms',
    'Warm mug radiating through fingers',
    'Soft sand heating in the afternoon sun',
  ];

  @override
  void initState() {
    super.initState();
    session = ExerciseSession(
      exerciseId: 'hand_warming',
      startTime: DateTime.now(),
    );
    session.moodBefore = _moodBefore;
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
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
          _warmthLevel = (_warmthLevel + 0.02).clamp(0.3, 1.0);
        });
      } else {
        _complete();
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

  Future<void> _complete() async {
    _timer?.cancel();

    setState(() {
      _isRunning = false;
      _isPaused = false;
    });

    session
      ..endTime = DateTime.now()
      ..moodAfter = _moodAfter
      ..extraData = {
        'total_seconds': _totalSeconds,
        'warmth_level': _warmthLevel,
        'visualization_used': _visuals.first,
      };

    await ExerciseService().saveSession(session);

    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final warmColor = Color.lerp(
      Theme.of(context).colorScheme.primary.withOpacity(0.2),
      Theme.of(context).colorScheme.tertiary.withOpacity(0.7),
      _warmthLevel,
    );

    return ExerciseScaffold(
      title: 'Hand Warming',
      subtitle: 'Use imagery to shift your nervous system',
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
                    'Mood check-in',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  _MoodSlider(
                    label: 'Before warming',
                    value: _moodBefore.toDouble(),
                    onChanged: (value) {
                      setState(() {
                        _moodBefore = value.round();
                        session.moodBefore = _moodBefore;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _MoodSlider(
                    label: 'After warming',
                    value: (_moodAfter ?? _moodBefore).toDouble(),
                    onChanged: (value) {
                      setState(() {
                        _moodAfter = value.round();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        warmColor ?? Colors.orangeAccent.withOpacity(0.2),
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      ],
                      stops: const [0.3, 1],
                    ),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _formatTime(_secondsRemaining),
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _visuals.first,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: _visuals
                      .map(
                        (visual) => ActionChip(
                          label: Text(visual),
                          onPressed: () {
                            setState(() {
                              _warmthLevel =
                                  (_warmthLevel + 0.1).clamp(0.3, 1.0);
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          ExerciseControlBar(
            onStart: _start,
            onPause: _pause,
            onStop: _complete,
            isRunning: _isRunning,
            isPaused: _isPaused,
          ),
        ],
      ),
    );
  }
}

class _MoodSlider extends StatelessWidget {
  const _MoodSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(value.round().toString()),
          ],
        ),
        Slider(
          value: value.clamp(1, 10),
          min: 1,
          max: 10,
          divisions: 9,
          label: value.round().toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
