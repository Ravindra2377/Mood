import 'package:flutter/material.dart';

class MeditationSession {
  final String id;
  final String name;
  final String icon;
  final String audioPath;

  MeditationSession({
    required this.id,
    required this.name,
    required this.icon,
    required this.audioPath,
  });
}

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
  int _selectedMusicIndex = 0;

  final List<MeditationSession> _musicOptions = [
    MeditationSession(
      id: 'ocean',
      name: 'Ocean breeze',
      icon: '🌊',
      audioPath: 'assets/audio/ocean_breeze.mp3',
    ),
    MeditationSession(
      id: 'rain',
      name: 'Rain sounds',
      icon: '🌧️',
      audioPath: 'assets/audio/rain_sounds.mp3',
    ),
    MeditationSession(
      id: 'forest',
      name: 'Forest birds',
      icon: '🌲',
      audioPath: 'assets/audio/forest_birds.mp3',
    ),
    MeditationSession(
      id: 'white_noise',
      name: 'White noise',
      icon: '🎵',
      audioPath: 'assets/audio/white_noise.mp3',
    ),
    MeditationSession(
      id: 'piano',
      name: 'Calm piano',
      icon: '🎹',
      audioPath: 'assets/audio/calm_piano.mp3',
    ),
    MeditationSession(
      id: 'meditation',
      name: 'Meditation bells',
      icon: '🔔',
      audioPath: 'assets/audio/meditation_bells.mp3',
    ),
    MeditationSession(
      id: 'nature',
      name: 'Nature symphony',
      icon: '🦅',
      audioPath: 'assets/audio/nature_symphony.mp3',
    ),
    MeditationSession(
      id: 'stream',
      name: 'Flowing stream',
      icon: '💧',
      audioPath: 'assets/audio/flowing_stream.mp3',
    ),
  ];

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
      appBar: AppBar(
        title: const Text('Breathing meditation'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Music selector
            Container(
              color: Colors.black87,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select ambient sound',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _musicOptions.length,
                      itemBuilder: (context, index) {
                        final isSelected = index == _selectedMusicIndex;
                        final option = _musicOptions[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedMusicIndex = index;
                              });
                            },
                            child: Container(
                              width: 70,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF00B894)
                                    : Colors.grey.shade800,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF00B894)
                                      : Colors.grey.shade700,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    option.icon,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    option.name.split(' ')[0],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey.shade400,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Meditation animation
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Text(
                    _musicOptions[_selectedMusicIndex].name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00B894),
                    ),
                  ),
                  const SizedBox(height: 30),
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
                ],
              ),
            ),
            // Play button and timer
            Column(
              children: [
                FilledButton.icon(
                  onPressed: () {
                    setState(() {
                      _playing = !_playing;
                      if (_playing) {
                        _ctrl.repeat(reverse: true);
                        // Audio playback would be triggered here
                        // _audioPlayer.play(_musicOptions[_selectedMusicIndex].audioPath);
                      } else {
                        _ctrl.stop();
                        // _audioPlayer.pause();
                      }
                    });
                  },
                  icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
                  label: Text(_playing ? 'Pause' : 'Start'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    backgroundColor: const Color(0xFF00B894),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '00:00',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Instructions
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF00B894).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF00B894).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '💡 How to get music working:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF00B894),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '1. Add this dependency to pubspec.yaml:\n   audioplayers: ^5.0.0\n\n'
                    '2. Place audio files in assets/audio/:\n'
                    '   • ocean_breeze.mp3\n'
                    '   • rain_sounds.mp3\n'
                    '   • forest_birds.mp3\n'
                    '   • white_noise.mp3\n'
                    '   • calm_piano.mp3\n'
                    '   • meditation_bells.mp3\n'
                    '   • nature_symphony.mp3\n'
                    '   • flowing_stream.mp3\n\n'
                    '3. Update pubspec.yaml assets section:\n'
                    '   assets:\n'
                    '     - assets/audio/\n\n'
                    '4. Uncomment audio playback code in this file.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
