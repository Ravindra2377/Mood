import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/ui_state.dart';
import '../data/appMockData.dart';

class EnhancedMeditationScreen extends ConsumerStatefulWidget {
  static const route = '/enhanced-meditation';

  const EnhancedMeditationScreen({super.key});

  @override
  ConsumerState<EnhancedMeditationScreen> createState() =>
      _EnhancedMeditationScreenState();
}

class _EnhancedMeditationScreenState
    extends ConsumerState<EnhancedMeditationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _togglePlay() {
    final meditationState = ref.read(meditationStateProvider);
    ref.read(meditationStateProvider.notifier).togglePlay();

    if (!meditationState.isPlaying) {
      _animController.repeat(reverse: true);
      _startTimer();
    } else {
      _animController.stop();
      _timer?.cancel();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final state = ref.read(meditationStateProvider);
      if (state.timerSeconds < state.duration) {
        ref.read(meditationStateProvider.notifier).updateTimer(state.timerSeconds + 1);
      } else {
        timer.cancel();
        _animController.stop();
        ref.read(meditationStateProvider.notifier).reset();
      }
    });
  }

  String _getBreathingText() {
    if (_animController.value < 0.5) {
      return 'Inhale...';
    } else {
      return 'Exhale...';
    }
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final gradient = Theme.of(context).extension<SoulGradients>()?.pastel ??
        const LinearGradient(colors: [Colors.blue, Colors.teal]);
    final meditationState = ref.watch(meditationStateProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    // Sound selector
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: DropdownButton<String>(
                        value: meditationState.selectedSound,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                        items: AppMockData.ambientSounds.map((sound) {
                          return DropdownMenuItem(
                            value: sound,
                            child: Row(
                              children: [
                                const Icon(Icons.music_note, size: 16),
                                const SizedBox(width: 8),
                                Text(sound),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            ref.read(meditationStateProvider.notifier).setSound(value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Duration
                Text(
                  '${meditationState.duration ~/ 60} minutes',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                // Title
                const Text(
                  'Breathing meditation',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                // Animated illustration
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    final scale = 0.85 + 0.15 * _animController.value;
                    return Transform.scale(
                      scale: scale,
                      child: child,
                    );
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB4D4F0).withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Image.asset(
                        'assets/images/meditation_brain.png',
                        width: 140,
                        height: 140,
                        fit: BoxFit.contain,
                      ),
                      Positioned(
                        bottom: 20,
                        child: Image.asset(
                          'assets/images/meditation_child.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Breathing text
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return Text(
                      meditationState.isPlaying ? _getBreathingText() : 'Inhale...',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
                const Spacer(),
                // Timer and play button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(meditationState.timerSeconds),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: _togglePlay,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            meditationState.isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SoulGradients extends ThemeExtension<SoulGradients> {
  final LinearGradient pastel;
  const SoulGradients({required this.pastel});

  @override
  SoulGradients copyWith({LinearGradient? pastel}) =>
      SoulGradients(pastel: pastel ?? this.pastel);

  @override
  ThemeExtension<SoulGradients> lerp(
    covariant ThemeExtension<SoulGradients>? other,
    double t,
  ) {
    if (other is! SoulGradients) return this;
    return t < .5 ? this : other;
  }
}