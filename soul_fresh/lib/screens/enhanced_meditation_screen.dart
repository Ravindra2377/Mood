import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class EnhancedMeditationScreen extends StatefulWidget {
  static const route = '/enhanced-meditation';

  const EnhancedMeditationScreen({super.key});

  @override
  State<EnhancedMeditationScreen> createState() =>
      _EnhancedMeditationScreenState();
}

class _EnhancedMeditationScreenState extends State<EnhancedMeditationScreen>
    with TickerProviderStateMixin {
  static const Duration _minDuration = Duration(seconds: 10);
  static const Duration _maxDuration = Duration(minutes: 60);

  int selectedMinutes = 5;
  int selectedSeconds = 0;
  int totalSeconds = 300;
  int remainingSeconds = 300;
  bool isRunning = false;
  bool isPaused = false;
  Timer? _timer;

  late final AnimationController _breathingController;
  late final AnimationController _rippleController;
  late final Animation<double> _breathingAnimation;
  late final Animation<double> _rippleAnimation;

  String breathingPhase = 'Inhale...';

  final List<String> ambientSounds = const [
    'Ocean breeze',
    'Forest rain',
    'Tibetan bowls',
    'White noise',
    'Silent',
  ];
  String selectedSound = 'Ocean breeze';

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    _breathingAnimation = CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    );

    _breathingController.addStatusListener((status) {
      if (!mounted) return;
      if (status == AnimationStatus.forward ||
          status == AnimationStatus.completed) {
        setState(() => breathingPhase = 'Inhale...');
      } else if (status == AnimationStatus.reverse ||
          status == AnimationStatus.dismissed) {
        setState(() => breathingPhase = 'Exhale...');
      }
    });

    _breathingController.repeat(reverse: true);

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _rippleAnimation = CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    );

    _rippleController.repeat();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathingController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (isRunning) return;

    setState(() {
      isRunning = true;
      isPaused = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds <= 1) {
        timer.cancel();
        _completeSession();
      } else {
        setState(() => remainingSeconds--);
      }
    });
  }

  void _pauseTimer() {
    if (!isRunning) return;
    _timer?.cancel();
    setState(() {
      isRunning = false;
      isPaused = true;
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      isRunning = false;
      isPaused = false;
      remainingSeconds = totalSeconds;
    });
  }

  Future<void> _completeSession() async {
    _timer?.cancel();
    setState(() {
      isRunning = false;
      isPaused = false;
      remainingSeconds = totalSeconds;
    });

    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(duration: 1000, amplitude: 128);
    }
    HapticFeedback.heavyImpact();

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text('Session Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Great job! You meditated for ${_formatDuration(totalSeconds)}.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'How do you feel?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => remainingSeconds = totalSeconds);
              _startTimer();
            },
            child: const Text('Meditate Again'),
          ),
        ],
      ),
    );
  }

  void _applyTimerSelection(Duration duration) {
    final clampedSeconds = duration.inSeconds
        .clamp(_minDuration.inSeconds, _maxDuration.inSeconds);
    setState(() {
      totalSeconds = clampedSeconds;
      remainingSeconds = clampedSeconds;
      selectedMinutes = clampedSeconds ~/ 60;
      selectedSeconds = clampedSeconds % 60;
    });
  }

  Future<void> _showTimerPicker() async {
    final initialDuration = Duration(
      minutes: selectedMinutes,
      seconds: selectedSeconds,
    );
    Duration tempDuration = initialDuration;

    Duration clampDuration(Duration duration) {
      final clampedSeconds = duration.inSeconds
          .clamp(_minDuration.inSeconds, _maxDuration.inSeconds)
          .toInt();
      return Duration(seconds: clampedSeconds);
    }

    final result = await showModalBottomSheet<Duration>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: StatefulBuilder(
            builder: (context, setModalState) => SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Set Timer',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final preset in [3, 5, 10, 15, 20, 30])
                        OutlinedButton(
                          onPressed: () {
                            setModalState(
                              () => tempDuration =
                                  clampDuration(Duration(minutes: preset)),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor:
                                (tempDuration.inMinutes == preset &&
                                        tempDuration.inSeconds % 60 == 0)
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.1)
                                    : null,
                          ),
                          child: Text('$preset min'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 200,
                    child: CupertinoTimerPicker(
                      key: ValueKey(tempDuration.inSeconds),
                      mode: CupertinoTimerPickerMode.ms,
                      initialTimerDuration: tempDuration,
                      onTimerDurationChanged: (duration) {
                        setModalState(
                          () => tempDuration = clampDuration(duration),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Selected: ${_formatDuration(tempDuration.inSeconds)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pop(context, clampDuration(tempDuration)),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Set Timer'),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tip: Minimum session length is 10 seconds and maximum is 60 minutes.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (!mounted || result == null) return;
    _applyTimerSelection(result);
  }

  void _showSoundPicker() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose Ambient Sound',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...ambientSounds.map(
              (sound) => ListTile(
                leading: Icon(
                  _getSoundIcon(sound),
                  color: selectedSound == sound ? Colors.blue : null,
                ),
                title: Text(sound),
                trailing: selectedSound == sound
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  setState(() => selectedSound = sound);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSoundIcon(String sound) {
    switch (sound) {
      case 'Ocean breeze':
        return Icons.waves;
      case 'Forest rain':
        return Icons.park;
      case 'Tibetan bowls':
        return Icons.music_note;
      case 'White noise':
        return Icons.graphic_eq;
      case 'Silent':
        return Icons.volume_off;
      default:
        return Icons.music_note;
    }
  }

  String _formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    if (mins > 0 && secs > 0) {
      return '$mins min $secs sec';
    } else if (mins > 0) {
      return mins == 1 ? '1 minute' : '$mins minutes';
    }
    return '$secs seconds';
  }

  @override
  Widget build(BuildContext context) {
    const gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1E88E5), Color(0xFF26A69A)],
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: gradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _showSoundPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getSoundIcon(selectedSound),
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              selectedSound,
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: isRunning ? null : _showTimerPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.timer,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatDuration(totalSeconds),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            if (!isRunning) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Breathing meditation',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _rippleAnimation,
                        builder: (context, child) {
                          final scale = 1 + (_rippleAnimation.value * 0.3);
                          final opacity = 0.1 * (1 - _rippleAnimation.value);
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 300,
                              height: 300,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: opacity),
                              ),
                            ),
                          );
                        },
                      ),
                      AnimatedBuilder(
                        animation: _breathingAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 250 * _breathingAnimation.value,
                            height: 250 * _breathingAnimation.value,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.4),
                                  Colors.white.withValues(alpha: 0.15),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                breathingPhase,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Text(
                  _formatTime(remainingSeconds),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isRunning || isPaused)
                      FloatingActionButton(
                        heroTag: 'stop',
                        onPressed: _stopTimer,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        child: const Icon(Icons.stop, color: Colors.white),
                      ),
                    if (isRunning || isPaused) const SizedBox(width: 16),
                    FloatingActionButton.extended(
                      heroTag: 'main',
                      onPressed: () {
                        if (isRunning) {
                          _pauseTimer();
                        } else {
                          _startTimer();
                        }
                      },
                      backgroundColor: Colors.white,
                      icon: Icon(
                        isRunning ? Icons.pause : Icons.play_arrow,
                        color: const Color(0xFF1E88E5),
                      ),
                      label: Text(
                        isRunning ? 'Pause' : (isPaused ? 'Resume' : 'Start'),
                        style: const TextStyle(
                          color: Color(0xFF1E88E5),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
