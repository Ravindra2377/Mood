import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ai/panda_ai.dart';
import '../ai/panda_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Playful animated panda that reacts to taps, moods, and persona changes.
class AnimatedPandaCompanion extends StatefulWidget {
  const AnimatedPandaCompanion({
    super.key,
    required this.mood,
    required this.message,
    this.size = 160,
    this.onTap,
    this.persona = PandaPersona.playfulBuddy,
    this.heroTag,
    this.showAmbientSparkles = true,
  });

  final PandaMood mood;
  final String message;
  final double size;
  final VoidCallback? onTap;
  final PandaPersona persona;
  final Object? heroTag;
  final bool showAmbientSparkles;

  @override
  State<AnimatedPandaCompanion> createState() => _AnimatedPandaCompanionState();
}

class _AnimatedPandaCompanionState extends State<AnimatedPandaCompanion>
    with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _wobbleController;
  late final AnimationController _blinkController;
  late final AnimationController _tapController;
  late final AnimationController _ambientController;
  late final Animation<double> _floatAnimation;
  late final Animation<double> _wobbleAnimation;
  late final Animation<double> _tapScaleAnimation;

  Timer? _blinkTimer;
  final Random _random = Random();
  late List<_Sparkle> _sparkles;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _wobbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );

    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _wobbleAnimation = Tween<double>(begin: -0.02, end: 0.02).animate(
      CurvedAnimation(parent: _wobbleController, curve: Curves.easeInOut),
    );

    _tapScaleAnimation = Tween<double>(begin: 1, end: 1.08).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeOutBack),
    );

    _sparkles = widget.showAmbientSparkles ? _generateSparkles() : <_Sparkle>[];
    _scheduleBlink();
  }

  @override
  void didUpdateWidget(covariant AnimatedPandaCompanion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.persona != oldWidget.persona ||
        widget.showAmbientSparkles != oldWidget.showAmbientSparkles) {
      _sparkles = widget.showAmbientSparkles ? _generateSparkles() : <_Sparkle>[];
    }
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _floatController.dispose();
    _wobbleController.dispose();
    _blinkController.dispose();
    _tapController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  void _scheduleBlink() {
    _blinkTimer?.cancel();
    _blinkTimer = Timer(Duration(seconds: 3 + _random.nextInt(3)), () async {
      if (!mounted) return;
      await _blinkController.forward(from: 0);
      if (!mounted) return;
      await _blinkController.reverse(from: 1);
      if (!mounted) return;
      _scheduleBlink();
    });
  }

  void _handleTap() {
    if (!_tapController.isAnimating) {
      _tapController.forward(from: 0).then((_) {
        if (mounted) {
          _tapController.reverse(from: 1);
        }
      });
    }

    try {
      HapticFeedback.lightImpact();
    } catch (_) {
      // Ignore if the platform does not support haptics.
    }
    widget.onTap?.call();
  }

  List<_Sparkle> _generateSparkles() {
    return List<_Sparkle>.generate(6, (index) {
      final base = index / 6;
      return _Sparkle(
        alignment: Alignment(
          (base * 2) - 1 + (_random.nextDouble() * 0.2 - 0.1),
          (_random.nextDouble() * 1.6) - 0.8,
        ),
        size: 14 + _random.nextDouble() * 8,
        phaseShift: _random.nextDouble() * 2 * pi,
        color: widget.persona.accentColor
            .withOpacity(0.65 - _random.nextDouble() * 0.2),
      );
    });
  }

  Color _bubbleColorForMood(PandaMood mood) {
    switch (mood) {
      case PandaMood.happy:
      case PandaMood.celebrate:
        return AppColors.happyPastel.withOpacity(0.4);
      case PandaMood.calm:
      case PandaMood.focus:
        return AppColors.calmPastel.withOpacity(0.35);
      case PandaMood.anxious:
        return AppColors.anxiousPastel.withOpacity(0.35);
      case PandaMood.sad:
        return AppColors.sadPastel.withOpacity(0.35);
      case PandaMood.lonely:
        return AppColors.coolPastel.withOpacity(0.35);
      case PandaMood.welcome:
        return AppColors.primaryPastel.withOpacity(0.4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bubbleColor = _bubbleColorForMood(widget.mood);
    final accent = widget.persona.accentColor.withOpacity(0.6);
    final blendedBubble = Color.alphaBlend(accent, bubbleColor);

    Widget pandaAvatar = GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _floatController,
          _wobbleController,
          _blinkController,
          _tapController,
          _ambientController,
        ]),
        builder: (context, child) {
          final double floatOffset = _floatAnimation.value;
          final double wobbleAngle = _wobbleAnimation.value;
          final double blinkScaleY = 1 - (_blinkController.value * 0.55);
          final double tapScale = _tapScaleAnimation.value;
          final double ambienceProgress = _ambientController.value;

          return Transform.translate(
            offset: Offset(0, floatOffset),
            child: Transform.rotate(
              angle: wobbleAngle,
              child: Transform.scale(
                scale: tapScale,
                child: Transform.scale(
                  scaleY: blinkScaleY.clamp(0.4, 1.0),
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          AppColors.whiteBg.withOpacity(0.8),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withOpacity(0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(12),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        child!,
                        if (widget.showAmbientSparkles)
                          ..._sparkles.map((sparkle) {
                            final double oscillation =
                                (sin((ambienceProgress * 2 * pi) + sparkle.phaseShift) + 1) / 2;
                            final double opacity =
                                (0.35 + (oscillation * 0.45)).clamp(0.0, 1.0);
                            final double scale = 0.8 + (oscillation * 0.35);

                            return Align(
                              alignment: sparkle.alignment,
                              child: Opacity(
                                opacity: opacity,
                                child: Transform.scale(
                                  scale: scale,
                                  child: Container(
                                    width: sparkle.size,
                                    height: sparkle.size,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: sparkle.color,
                                      boxShadow: [
                                        BoxShadow(
                                          color: sparkle.color.withOpacity(0.5),
                                          blurRadius: sparkle.size * 0.8,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        child: Image.asset(
          'soul_fresh/assets/images/panda_mascot_green.png',
          fit: BoxFit.contain,
        ),
      ),
    );

    if (widget.heroTag != null) {
      pandaAvatar = Hero(
        tag: widget.heroTag!,
        child: Material(
          color: Colors.transparent,
          child: pandaAvatar,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        pandaAvatar,
        const SizedBox(height: 20),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          constraints: const BoxConstraints(maxWidth: 320),
          decoration: BoxDecoration(
            color: blendedBubble,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accent.withOpacity(0.9), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.45),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutQuart,
            switchOutCurve: Curves.easeInQuart,
            child: Text(
              widget.message,
              key: ValueKey(widget.message),
              style: AppTypography.body1.copyWith(
                color: AppColors.charcoal,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

class _Sparkle {
  const _Sparkle({
    required this.alignment,
    required this.size,
    required this.phaseShift,
    required this.color,
  });

  final Alignment alignment;
  final double size;
  final double phaseShift;
  final Color color;
}
