import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/exercise_models.dart';
import '../../services/exercise_service.dart';
import '../../widgets/control_bar.dart';
import '../../widgets/exercise_scaffold.dart';

class ButterflyHugScreen extends StatefulWidget {
  const ButterflyHugScreen({super.key});

  @override
  State<ButterflyHugScreen> createState() => _ButterflyHugScreenState();
}

class _ButterflyHugScreenState extends State<ButterflyHugScreen> {
  static const int _totalSeconds = 120;

  late ExerciseSession session;
  Timer? _timer;
  bool _isRunning = false;
  bool _isPaused = false;
  bool _leftTap = true;
  int _secondsRemaining = _totalSeconds;
  int _moodBefore = 4;
  int? _moodAfter;

  final List<String> _affirmations = const [
    'I am safe in this moment.',
    'Each tap settles my nervous system.',
    'I can come back to my body gently.',
  ];

  @override
  void initState() {
    super.initState();
    session = ExerciseSession(
      exerciseId: 'butterfly_hug',
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
          _leftTap = !_leftTap;
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
        'mood_before': _moodBefore,
        'mood_after': _moodAfter,
        'affirmation_used': _affirmations.first,
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
    return ExerciseScaffold(
      title: 'Butterfly Hug',
      subtitle: 'Gentle bilateral tapping',
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
                    label: 'Before tapping',
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
                    label: 'After tapping',
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _TapIndicator(active: _leftTap),
                    const SizedBox(width: 24),
                    Icon(Icons.self_improvement,
                        size: 72, color: Theme.of(context).primaryColor,),
                    const SizedBox(width: 24),
                    _TapIndicator(active: !_leftTap),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Cross arms over chest. Tap alternately just below your collarbones.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  _formatTime(_secondsRemaining),
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  _affirmations.first,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontStyle: FontStyle.italic),
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

class _TapIndicator extends StatelessWidget {
  const _TapIndicator({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surfaceContainerHighest,
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
