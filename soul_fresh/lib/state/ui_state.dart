import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_models.dart';

// UI State providers for the mental health app

// Time filter state
final timeFilterProvider = StateProvider<TimeFilter>((ref) => TimeFilter.today);

// Selected mood state
final selectedMoodProvider = StateProvider<MoodLevel?>((ref) => null);

// Navigation state
final navigationProvider =
    StateProvider<NavigationSection>((ref) => NavigationSection.home);

// Meditation state
class MeditationState {
  final bool isPlaying;
  final int timerSeconds;
  final int duration;
  final String selectedSound;

  const MeditationState({
    required this.isPlaying,
    required this.timerSeconds,
    required this.duration,
    required this.selectedSound,
  });

  MeditationState copyWith({
    bool? isPlaying,
    int? timerSeconds,
    int? duration,
    String? selectedSound,
  }) {
    return MeditationState(
      isPlaying: isPlaying ?? this.isPlaying,
      timerSeconds: timerSeconds ?? this.timerSeconds,
      duration: duration ?? this.duration,
      selectedSound: selectedSound ?? this.selectedSound,
    );
  }
}

class MeditationStateNotifier extends StateNotifier<MeditationState> {
  MeditationStateNotifier()
      : super(
          const MeditationState(
            isPlaying: false,
            timerSeconds: 0,
            duration: 300, // 5 minutes default
            selectedSound: 'Ocean breeze',
          ),
        );

  void togglePlay() {
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  void updateTimer(int seconds) {
    state = state.copyWith(timerSeconds: seconds);
  }

  void setSound(String sound) {
    state = state.copyWith(selectedSound: sound);
  }

  void reset() {
    state = state.copyWith(isPlaying: false, timerSeconds: 0);
  }
}

final meditationStateProvider =
    StateNotifierProvider<MeditationStateNotifier, MeditationState>(
  (ref) => MeditationStateNotifier(),
);

// Journal entry state
final journalEntryProvider = StateProvider<String>((ref) => '');

// Selected calendar day state
final selectedCalendarDayProvider = StateProvider<int>((ref) => 22);

// Search query state
final searchQueryProvider = StateProvider<String>((ref) => '');
