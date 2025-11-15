import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/exercise_models.dart';
import '../../services/exercise_service.dart';
import '../../widgets/control_bar.dart';
import '../../widgets/exercise_scaffold.dart';

class StreamConsciousnessScreen extends StatefulWidget {
  const StreamConsciousnessScreen({super.key});

  @override
  State<StreamConsciousnessScreen> createState() =>
      _StreamConsciousnessScreenState();
}

class _StreamConsciousnessScreenState extends State<StreamConsciousnessScreen> {
  static const int _totalSeconds = 10 * 60;

  late ExerciseSession session;
  final TextEditingController _writingController = TextEditingController();
  final TextEditingController _insightController = TextEditingController();
  final FocusNode _writingFocusNode = FocusNode();

  Timer? _timer;
  int _remainingSeconds = _totalSeconds;
  bool _isRunning = false;
  bool _isPaused = false;
  bool _timerCompleted = false;

  final List<String> _prompts = const [
    'Start with “Right now I notice…” and keep going.',
    'Describe what is catching your attention in this exact moment.',
    'If you get stuck, write the same sentence repeatedly until new ideas flow.',
    'What would you write if nobody else would ever read this?',
  ];

  String? _activePrompt;
  int _moodBefore = 5;
  int? _moodAfter;

  int get _wordCount {
    final text = _writingController.text.trim();
    if (text.isEmpty) {
      return 0;
    }
    return text.split(RegExp(r'\s+')).length;
  }

  @override
  void initState() {
    super.initState();
    session = ExerciseSession(
      exerciseId: 'stream_consciousness',
      startTime: DateTime.now(),
    );
    session.moodBefore = _moodBefore;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _writingController.dispose();
    _insightController.dispose();
    _writingFocusNode.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning && !_isPaused) {
      return;
    }

    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    _writingFocusNode.requestFocus();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _handleTimerComplete();
      }
    });
  }

  void _pauseTimer() {
    if (!_isRunning) {
      return;
    }

    _timer?.cancel();
    setState(() {
      _isPaused = true;
      _isRunning = false;
    });
  }

  void _handleTimerComplete() {
    _timer?.cancel();
    setState(() {
      _timerCompleted = true;
      _isRunning = false;
      _isPaused = false;
      _remainingSeconds = 0;
    });
    _showTimerFinishedSnackBar();
  }

  Future<void> _completeExercise() async {
    FocusScope.of(context).unfocus();

    if (_writingController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Write for a few minutes before finishing.'),
        ),
      );
      return;
    }

    session
      ..endTime = DateTime.now()
      ..moodBefore = _moodBefore
      ..moodAfter = _moodAfter
      ..notes = _insightController.text.trim().isEmpty
          ? null
          : _insightController.text.trim()
      ..extraData = {
        'word_count': _wordCount,
        'prompt': _activePrompt,
        'timer_completed': _timerCompleted,
        'remaining_seconds': _remainingSeconds,
        'text': _writingController.text,
      };

    await ExerciseService().saveSession(session);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Entry saved. Nice work.')),
    );
    Navigator.of(context).pop();
  }

  void _showTimerFinishedSnackBar() {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('10 minutes are up — capture your reflections.'),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return ExerciseScaffold(
      title: 'Stream of Consciousness',
      subtitle: '10-minute writing sprint',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Timer',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      _formatTime(_remainingSeconds),
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 48,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Mood before: $_moodBefore/10'),
                    Text('Mood after: ${_moodAfter ?? '—'}/10'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildMoodSliders(),
          const SizedBox(height: 12),
          Text(
            'Jump-start ideas',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _prompts
                .map(
                  (prompt) => ChoiceChip(
                    label: Text(prompt),
                    selected: _activePrompt == prompt,
                    onSelected: (_) {
                      setState(() {
                        _activePrompt = prompt;
                      });
                      if (_writingController.text.trim().isEmpty) {
                        _writingController.text = '$prompt\n\n';
                        _writingController.selection =
                            TextSelection.fromPosition(
                          TextPosition(offset: _writingController.text.length),
                        );
                      }
                      _writingFocusNode.requestFocus();
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: [
                TextField(
                  controller: _writingController,
                  focusNode: _writingFocusNode,
                  decoration: InputDecoration(
                    hintText: _activePrompt ??
                        'Keep writing without editing yourself…',
                    border: const OutlineInputBorder(),
                  ),
                  minLines: 10,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Word count: $_wordCount',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Text(
                      _timerCompleted
                          ? 'Timer complete'
                          : 'Time left: ${_formatTime(_remainingSeconds)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Final reflections',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _insightController,
                  decoration: const InputDecoration(
                    hintText: 'Anything new you noticed while writing?',
                    border: OutlineInputBorder(),
                  ),
                  minLines: 3,
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ExerciseControlBar(
            onStart: _startTimer,
            onPause: _pauseTimer,
            onStop: _completeExercise,
            isRunning: _isRunning,
            isPaused: _isPaused,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _completeExercise,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Save entry'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSliders() {
    return Column(
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
          label: 'Before writing',
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
          label: 'After writing',
          value: (_moodAfter ?? _moodBefore).toDouble(),
          onChanged: (value) {
            setState(() {
              _moodAfter = value.round();
            });
          },
        ),
      ],
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
