import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soul_fresh/config/app_colors.dart';
import 'package:soul_fresh/screens/mental_health/stress_management_screen.dart';
import 'package:soul_fresh/screens/mental_health/mood_tracking_screen.dart';
import 'package:soul_fresh/screens/mental_health/sleep_tracking_screen.dart';
import 'package:soul_fresh/screens/mental_health/mindfulness_screen.dart';
import 'package:soul_fresh/screens/mental_health/anxiety_management_screen.dart';
import 'package:soul_fresh/screens/mental_health/wellness_screen.dart';

// Provider to track current tab
final mentalHealthTabProvider = StateProvider<int>((ref) => 0);

class MentalHealthDashboard extends ConsumerWidget {
  const MentalHealthDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(mentalHealthTabProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: IndexedStack(
        index: currentTab,
        children: const [
          StressTrackingScreen(),
          MoodTrackingScreen(),
          SleepTrackingScreen(),
          MindfulnessScreen(),
          AnxietyManagementScreen(),
          WellnessScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTab,
        onTap: (index) {
          ref.read(mentalHealthTabProvider.notifier).state = index;
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.cardColor,
        selectedItemColor: const Color(0xFF6C5CE7),
        unselectedItemColor: AppColors.secondaryText,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology),
            label: 'Stress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mood),
            label: 'Mood',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bed_time),
            label: 'Sleep',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Mindfulness',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes),
            label: 'Anxiety',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Wellness',
          ),
        ],
      ),
    );
  }
}
