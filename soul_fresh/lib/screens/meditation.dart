import 'package:flutter/material.dart';

class MeditationScreen extends StatefulWidget {
  static const route = '/meditation';
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Breathing meditation')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _ctrl,
              builder: (context, child) {
                final t = 0.8 + 0.2 * _ctrl.value;
                return Transform.scale(
                  scale: t,
                  child: child,
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Image.asset('assets/images/meditation_child.png',
                      width: 150, height: 150, fit: BoxFit.contain),
                  const Positioned(
                    bottom: 16,
                    child: Text('Inhale...',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                setState(() {
                  _playing = !_playing;
                  if (_playing) {
                    _ctrl.repeat(reverse: true);
                  } else {
                    _ctrl.stop();
                  }
                });
              },
              icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
              label: Text(_playing ? 'Pause' : 'Start'),
            ),
          ],
        ),
      ),
    );
  }
}
