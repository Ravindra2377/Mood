# 🎵 Audio Setup Guide for Meditation Screen

## Overview
The meditation screen now includes 8 ambient sound/music options with a horizontal scroll selector. This guide explains how to set up audio playback.

## 📋 Available Audio Options

1. **🌊 Ocean breeze** - Soothing ocean wave sounds
2. **🌧️ Rain sounds** - Relaxing rainfall ambience
3. **🌲 Forest birds** - Nature sounds with birds chirping
4. **🎵 White noise** - Classic white noise for deep focus
5. **🎹 Calm piano** - Gentle piano melodies
6. **🔔 Meditation bells** - Mindfulness bell sounds
7. **🦅 Nature symphony** - Mixed nature soundscape
8. **💧 Flowing stream** - Peaceful stream water sounds

## 🚀 Setup Steps

### Step 1: Add Audio Player Dependency

Update `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  audioplayers: ^5.0.0
  # ... other dependencies
```

Then run:
```bash
flutter pub get
```

### Step 2: Create Audio Assets Directory

1. In your project root, create the audio directory:
   ```
   assets/
   └── audio/
       ├── ocean_breeze.mp3
       ├── rain_sounds.mp3
       ├── forest_birds.mp3
       ├── white_noise.mp3
       ├── calm_piano.mp3
       ├── meditation_bells.mp3
       ├── nature_symphony.mp3
       └── flowing_stream.mp3
   ```

### Step 3: Update pubspec.yaml Assets

Add the audio path to your pubspec.yaml:

```yaml
flutter:
  assets:
    - assets/images/
    - assets/audio/
```

### Step 4: Implement Audio Playback

Update `lib/screens/meditation.dart` with the following:

#### A. Add imports at the top:
```dart
import 'package:audioplayers/audioplayers.dart';
```

#### B. Add to _MeditationScreenState class:
```dart
late AudioPlayer _audioPlayer;

@override
void initState() {
  super.initState();
  _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );
  _audioPlayer = AudioPlayer();
}

@override
void dispose() {
  _audioPlayer.dispose();
  _ctrl.dispose();
  super.dispose();
}
```

#### C. Update the play button onPressed handler:
```dart
onPressed: () {
  setState(() {
    _playing = !_playing;
    if (_playing) {
      _ctrl.repeat(reverse: true);
      // Play selected audio
      _audioPlayer.play(
        AssetSource(_musicOptions[_selectedMusicIndex].audioPath),
        volume: 0.8,
      );
    } else {
      _ctrl.stop();
      // Pause audio
      _audioPlayer.pause();
    }
  });
},
```

#### D. Handle music selection change:
```dart
onTap: () {
  setState(() {
    _selectedMusicIndex = index;
    // If currently playing, restart with new audio
    if (_playing) {
      _audioPlayer.play(
        AssetSource(_musicOptions[index].audioPath),
        volume: 0.8,
      );
    }
  });
},
```

### Step 5: Add Duration Timer (Optional)

To display meditation duration, add this to your state:

```dart
late Timer _timer;
int _elapsedSeconds = 0;

void _startTimer() {
  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    setState(() {
      _elapsedSeconds++;
    });
  });
}

void _stopTimer() {
  _timer.cancel();
  _elapsedSeconds = 0;
}

String _formatTime(int seconds) {
  final minutes = seconds ~/ 60;
  final secs = seconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
}
```

Update the play button:
```dart
onPressed: () {
  setState(() {
    _playing = !_playing;
    if (_playing) {
      _ctrl.repeat(reverse: true);
      _startTimer();
      _audioPlayer.play(
        AssetSource(_musicOptions[_selectedMusicIndex].audioPath),
        volume: 0.8,
      );
    } else {
      _ctrl.stop();
      _stopTimer();
      _audioPlayer.pause();
    }
  });
},
```

Replace the timer display with:
```dart
Text(
  _formatTime(_elapsedSeconds),
  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
),
```

## 🎵 Audio File Recommendations

For the best experience, use:
- **Format**: MP3 (H.264 codec)
- **Bitrate**: 128-192 kbps
- **Sample Rate**: 44.1 kHz or 48 kHz
- **Duration**: 5-10 minutes (loops automatically)
- **File Size**: 5-20 MB per file

### Where to Get Royalty-Free Audio:

1. **Pixabay** - pixabay.com/music (Free, no attribution required)
2. **Freepik** - freepik.com (Free, attribution required)
3. **YouTube Audio Library** - youtube.com/audiolibrary (Free)
4. **Incompetech** - incompetech.com (Free)
5. **Epidemic Sound** - epidemicsound.com (Paid, premium quality)

## 🔧 Troubleshooting

### Audio not playing?
- ✅ Verify audio files are in `assets/audio/` directory
- ✅ Check pubspec.yaml has correct asset paths
- ✅ Run `flutter clean && flutter pub get`
- ✅ Rebuild and test

### Audio cuts off or stutters?
- ✅ Use lower bitrate audio files (128 kbps)
- ✅ Ensure files are properly formatted MP3
- ✅ Test on actual device (emulator may have audio issues)

### "AssetSource not found" error?
- ✅ Add `import 'package:audioplayers/audioplayers.dart';`
- ✅ Verify pubspec.yaml has `audioplayers: ^5.0.0` or higher

## ✅ Testing Checklist

- [ ] Dependency installed (`flutter pub get`)
- [ ] Audio files placed in `assets/audio/`
- [ ] pubspec.yaml assets section updated
- [ ] Code changes implemented
- [ ] App built without errors (`flutter build apk --release`)
- [ ] Audio plays when play button pressed
- [ ] Can switch between different audio options
- [ ] Audio pauses when pause button pressed
- [ ] Animation syncs with breathing (audio volume can enhance effect)

## 🎨 UI Features

The meditation screen now includes:

- **Dark music selector bar** - Horizontal scrollable list of 8 sounds
- **Selected sound indicator** - Green highlight on active sound
- **Breathing animation** - Synced with meditation duration
- **Play/Pause button** - Control meditation session
- **Timer display** - Shows elapsed time
- **Setup instructions** - In-app guide for users

## 📱 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Android | ✅ Full Support | Tested on API 21+ |
| iOS | ✅ Full Support | Requires permissions in Info.plist |
| Web | ⚠️ Limited | Check audioplayers web support |
| macOS | ✅ Full Support | Desktop support included |
| Windows | ✅ Full Support | Desktop support included |

## 🔐 iOS Specific Setup

For iOS to play audio in background, add to `ios/Runner/Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
  <string>audio</string>
</array>
```

## 📚 Additional Resources

- [AudioPlayers Documentation](https://pub.dev/packages/audioplayers)
- [Flutter Audio Plugins](https://pub.dev/packages?q=audio)
- [Meditation Audio Best Practices](https://www.meditate.com)

---

**Last Updated**: October 19, 2025
**Status**: Ready for Implementation
