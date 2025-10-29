import 'package:flutter/material.dart';

import 'screens/exercises_main_screen.dart';
import 'screens/breathing/box_breathing_screen.dart';
import 'screens/breathing/four_seven_eight_screen.dart';
import 'screens/breathing/resonant_breathing_screen.dart';
import 'screens/breathing/alternate_nostril_screen.dart';
import 'screens/relaxation/full_body_pmr_screen.dart';
import 'screens/relaxation/quick_pmr_screen.dart';
import 'screens/grounding/five_four_three_two_one_screen.dart';
import 'screens/cognitive/thought_challenging_screen.dart';
import 'screens/cognitive/worry_time_screen.dart';
import 'screens/journaling/stream_consciousness_screen.dart';
import 'screens/journaling/gratitude_journal_screen.dart';
import 'screens/visualization/safe_place_screen.dart';
import 'screens/visualization/success_visualization_screen.dart';
import 'screens/movement/yoga_flow_screen.dart';
import 'screens/movement/desk_stretches_screen.dart';
import 'screens/crisis/tipp_skills_screen.dart';
import 'screens/crisis/stop_technique_screen.dart';
import 'screens/sleep/sleep_meditation_screen.dart';
import 'screens/emotional/emotion_wheel_screen.dart';
import 'screens/emotional/butterfly_hug_screen.dart';
import 'screens/emotional/hand_warming_screen.dart';

final Map<String, WidgetBuilder> exerciseRouteBuilders =
    <String, WidgetBuilder>{
  ExercisesMainScreen.route: (_) => const ExercisesMainScreen(),
  '/exercises/box-breathing': (_) => const BoxBreathingScreen(),
  '/exercises/4-7-8-breathing': (_) => const FourSevenEightScreen(),
  '/exercises/resonant-breathing': (_) => const ResonantBreathingScreen(),
  '/exercises/alternate-nostril': (_) => const AlternateNostrilScreen(),
  '/exercises/full-body-pmr': (_) => const FullBodyPMRScreen(),
  '/exercises/quick-pmr': (_) => const QuickPMRScreen(),
  '/exercises/5-4-3-2-1-grounding': (_) => const FiveFourThreeTwoOneScreen(),
  '/exercises/thought-challenging': (_) => const ThoughtChallengingScreen(),
  '/exercises/worry-time': (_) => const WorryTimeScreen(),
  '/exercises/stream-consciousness': (_) => const StreamConsciousnessScreen(),
  '/exercises/gratitude-journal': (_) => const GratitudeJournalScreen(),
  '/exercises/safe-place': (_) => const SafePlaceScreen(),
  '/exercises/success-visualization': (_) => const SuccessVisualizationScreen(),
  '/exercises/yoga-flow': (_) => const YogaFlowScreen(),
  '/exercises/desk-stretches': (_) => const DeskStretchesScreen(),
  '/exercises/tipp-skills': (_) => const TippSkillsScreen(),
  '/exercises/stop-technique': (_) => const StopTechniqueScreen(),
  '/exercises/sleep-meditation': (_) => const SleepMeditationScreen(),
  '/exercises/emotion-wheel': (_) => const EmotionWheelScreen(),
  '/exercises/butterfly-hug': (_) => const ButterflyHugScreen(),
  '/exercises/hand-warming': (_) => const HandWarmingScreen(),
};

Route<dynamic>? createExerciseRoute(RouteSettings settings) {
  final builder = exerciseRouteBuilders[settings.name];
  if (builder == null) return null;
  return MaterialPageRoute<void>(
    builder: builder,
    settings: settings,
  );
}
