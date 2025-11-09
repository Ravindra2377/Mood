import 'dart:async';
import 'package:flutter/material.dart';
import '../models/exercise.dart';

class BoxBreathingScreen extends StatefulWidget {
  final Exercise exercise;

  const BoxBreathingScreen({required this.exercise, super.key});

  @override
  State<BoxBreathingScreen> createState() => _BoxBreathingScreenState();
}

class _BoxBreathingScreenState extends State<BoxBreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Timer _timer;
  late Timer _mainTimer;

  static const int _phaseDuration = 4; // seconds per phase
  static const List<String> _phases = ['Inhale', 'Hold', 'Exhale', 'Hold'];
  static const List<String> _instructions = [
    'Breathe in slowly and deeply',
    'Keep holding your breath',
    'Breathe out slowly and calmly',
    'Hold empty for a moment',
  ];

  int _currentPhase = 0;
  int _secondsInPhase = _phaseDuration;
  int _totalSeconds = 0;
  int _cyclesCompleted = 0;
  bool _isPlaying = false;
  final int _moodBefore = 5; // Default mood (1-10)
  int _moodAfter = 5;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _phaseDuration),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _mainTimer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Color _getPhaseColor() {
    switch (_currentPhase) {
      case 0:
        return const Color(0xFF64B5F6); // Inhale - Blue
      case 1:
        return const Color(0xFF81C784); // Hold - Green
      case 2:
        return const Color(0xFFFFB74D); // Exhale - Orange
      case 3:
        return const Color(0xFFBA68C8); // Hold - Purple
      default:
        return Colors.grey;
    }
  }

  void _startBreathing() {
    setState(() => _isPlaying = true);
    _startPhase();
  }

  void _pauseBreathing() {
    setState(() => _isPlaying = false);
    _timer.cancel();
  }

  void _resumeBreathing() {
    setState(() => _isPlaying = true);
    _startPhase();
  }

  void _restart() {
    _timer.cancel();
    _mainTimer.cancel();
    setState(() {
      _currentPhase = 0;
      _secondsInPhase = _phaseDuration;
      _totalSeconds = 0;
      _cyclesCompleted = 0;
      _isPlaying = false;
    });
  }

  void _startPhase() {
    _secondsInPhase = _phaseDuration;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPlaying) {
        timer.cancel();
        return;
      }

      if (_secondsInPhase > 1) {
        setState(() {
          _secondsInPhase--;
          _totalSeconds++;
        });
      } else {
        timer.cancel();
        _nextPhase();
      }
    });

    _animationController.forward(from: 0.0);
  }

  void _nextPhase() {
    if (!_isPlaying) return;

    setState(() {
      _currentPhase = (_currentPhase + 1) % _phases.length;
      if (_currentPhase == 0) {
        _cyclesCompleted++;
      }
    });
    _startPhase();
  }

  void _completeExercise() {
    _pauseBreathing();
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('âœ“ Great Job!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Duration: ${_totalSeconds ~/ 60}:${(_totalSeconds % 60).toString().padLeft(2, '0')}',
            ),
            const SizedBox(height: 12),
            const Text('How are you feeling now?'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                5,
                (i) => GestureDetector(
                  onTap: () {
                    setState(() => _moodAfter = i + 1);
                    Navigator.pop(context);
                  },
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: i + 1 <= _moodAfter
                          ? Colors.blue.shade600
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _saveSession();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _saveSession() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Session saved! Mood improved: $_moodBefore â†’ $_moodAfter',
        ),
        backgroundColor: Colors.green,
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getPhaseColor().withValues(alpha: 0.3),
              Colors.teal.withValues(alpha: 0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Box Breathing',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              // Main Content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Phase Name
                    Text(
                      _phases[_currentPhase],
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: _getPhaseColor(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Phase Instruction
                    Text(
                      _instructions[_currentPhase],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Animated Circle
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        final animationValue = _animationController.value;
                        final scaleFactor =
                            (_currentPhase == 0 || _currentPhase == 2)
                                ? 0.5 +
                                    (animationValue *
                                        0.5) // Expand on inhale/exhale
                                : 1.0 -
                                    (animationValue *
                                        0.3); // Slightly contract on hold

                        return Transform.scale(
                          scale: scaleFactor,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getPhaseColor().withValues(alpha: 0.2),
                              border: Border.all(
                                color: _getPhaseColor(),
                                width: 3,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '$_secondsInPhase',
                                style: TextStyle(
                                  fontSize: 60,
                                  fontWeight: FontWeight.bold,
                                  color: _getPhaseColor(),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                    // Timer and Cycles
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  const Text(
                                    'Total Time',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_totalSeconds ~/ 60}:${(_totalSeconds % 60).toString().padLeft(2, '0')}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text(
                                    'Cycles',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$_cyclesCompleted',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Controls
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Control Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isPlaying ? null : _startBreathing,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isPlaying
                                ? Colors.grey.shade300
                                : const Color(0xFF26A69A),
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start'),
                        ),
                        const SizedBox(width: 12),
                        if (_isPlaying)
                          ElevatedButton.icon(
                            onPressed: _pauseBreathing,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.pause),
                            label: const Text('Pause'),
                          ),
                        if (!_isPlaying && _totalSeconds > 0)
                          ElevatedButton.icon(
                            onPressed: _resumeBreathing,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Resume'),
                          ),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: _restart,
                          icon: const Icon(Icons.refresh),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Complete Button
                    if (_totalSeconds > 0)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _completeExercise,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text(
                            'Complete Exercise',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
