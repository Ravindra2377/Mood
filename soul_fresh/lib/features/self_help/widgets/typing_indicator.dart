/// Typing indicator widget showing animated dots.
/// Displays when AI is generating a response.
library;

import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  final Color? color;

  const TypingIndicator({super.key, this.color});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;

  @override
  void initState() {
    super.initState();

    _animationControllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    // Start animations immediately with staggered initial phase to avoid timers
    for (var i = 0; i < _animationControllers.length; i++) {
      final controller = _animationControllers[i];
      // Set an initial value to create a phase offset between dots
      controller.value = (i * 0.2).clamp(0.0, 1.0);
      controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.teal.shade400],
              ),
            ),
            child: const Center(
              child: Text('🤖', style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade800
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: List.generate(
                3,
                (index) => AnimatedBuilder(
                  animation: _animationControllers[index],
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        0,
                        _animationControllers[index].value * -8,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (widget.color ?? Colors.grey).withOpacity(
                              0.5 + (_animationControllers[index].value * 0.5),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
