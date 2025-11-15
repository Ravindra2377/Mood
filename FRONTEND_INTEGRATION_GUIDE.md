# Mental Health Frontend Integration Guide

## Overview

This guide provides complete instructions for integrating the 6 mental health tracking screens into your Flutter application. All screens are built with Riverpod state management, Material Design 3, and follow consistent UI/UX patterns.

## Project Structure

```
lib/screens/
├── mental_health_dashboard.dart          # Master dashboard with bottom navigation
├── mental_health/
│   ├── stress_management_screen.dart     # Stress tracking (450+ lines)
│   ├── mood_tracking_screen.dart         # Mood tracking (500+ lines)
│   ├── sleep_tracking_screen.dart        # Sleep tracking (450+ lines)
│   ├── mindfulness_screen.dart           # Meditation & mindfulness (500+ lines)
│   ├── anxiety_management_screen.dart    # Anxiety management (550+ lines)
│   └── wellness_screen.dart              # Wellness dashboard (450+ lines)
```

## Complete Feature List

### 1. Stress Management Screen
**File**: `lib/screens/mental_health/stress_management_screen.dart`

#### Tabs:
- **Track Tab**: Log stress levels (1-10 slider), view recent logs, add triggers and notes
- **Exercises Tab**: Access 4 guided exercises (4-7-8 Breathing, Progressive Muscle Relaxation, Box Breathing, Stress Relief Meditation)
- **Analytics Tab**: View average stress, trend analysis, top triggers, most effective exercises

#### Key Features:
- Stress level tracking with slider control
- Recent stress history with timestamps
- Pre-configured exercise library
- Analytics dashboard with trend visualization
- Trigger tracking and analysis
- Color-coded UI (purple theme: #6C5CE7)

#### Data Models:
```dart
class StressLog {
  final int id;
  final DateTime bedtime;        // Note: reused for flexibility
  final DateTime wakeTime;
  final double durationHours;    // Stress level 1-10
  final int qualityRating;       // Effectiveness rating
  final String? notes;
}

class StressAnalytics {
  final double averageDuration;
  final double averageQuality;
  final String trend;
  final double sleepDebt;        // Stress accumulation
  final List<Map<String, dynamic>> factors;
}
```

#### Providers:
- `stressLogsProvider`: List of stress entries
- `stressAnalyticsProvider`: Analytics data

---

### 2. Mood Tracking Screen
**File**: `lib/screens/mental_health/mood_tracking_screen.dart`

#### Tabs:
- **Today Tab**: Select mood level (6 emoji levels), log activities, write gratitude journal
- **Calendar Tab**: Month view of mood tracking, visual indicators for tracked days
- **Insights Tab**: Weekly average mood, top mood boosters, mood-activity correlations

#### Key Features:
- 6-level emoji mood selector (😢😟😐😊😄😁)
- Activity grid with 6 common mood-boosting activities
- Calendar view for historical tracking
- Gratitude journal input
- Mood insights with trend detection
- Color-coded UI (teal theme: varies)

#### Data Models:
```dart
class MoodEntry {
  final int id;
  final DateTime mood;           // Encoded as mood level
  final String activity;
  final DateTime timestamp;
  final String? notes;
}

class MoodInsights {
  final double averageMood;
  final String trend;
  final List<String> topActivities;
  final List<Map<String, dynamic>> triggers;
}
```

#### Providers:
- `moodEntriesProvider`: List of mood entries
- `moodInsightsProvider`: Insights data

---

### 3. Sleep Tracking Screen
**File**: `lib/screens/mental_health/sleep_tracking_screen.dart`

#### Tabs:
- **Log Tab**: Record sleep times (bedtime/wake time picker), quality rating (1-5 stars)
- **Analytics Tab**: Average sleep duration, quality rating, sleep debt, factors affecting sleep
- **Tips Tab**: 6 evidence-based sleep hygiene tips with emojis

#### Key Features:
- Time picker for bedtime and wake time
- Sleep quality rating with star system
- 7-day sleep history
- Sleep debt calculation
- Factor analysis (caffeine, exercise, schedule consistency, etc.)
- Sleep hygiene tips library
- Color-coded UI (purple theme: #6C5CE7)

#### Data Models:
```dart
class SleepLog {
  final int id;
  final DateTime bedtime;
  final DateTime wakeTime;
  final double durationHours;
  final int qualityRating;      // 1-5 stars
  final String? notes;
}

class SleepAnalytics {
  final double averageDuration;
  final double averageQuality;
  final String trend;
  final double sleepDebt;
  final List<Map<String, dynamic>> factors;
}
```

#### Providers:
- `sleepLogsProvider`: List of sleep entries
- `sleepAnalyticsProvider`: Analytics data

---

### 4. Mindfulness & Meditation Screen
**File**: `lib/screens/mental_health/mindfulness_screen.dart`

#### Tabs:
- **Sessions Tab**: Start new meditation, view recent sessions with focus ratings
- **Library Tab**: 6 meditation categories (Breathing, Body Scan, Loving Kindness, Sleep, Movement, Focus) with session counts
- **Stats Tab**: Streaks, total sessions, total minutes, focus ratings, 9 achievements

#### Key Features:
- Meditation session logging with duration and focus rating
- Meditation library with 6 categories
- Session history with ratings
- Streak tracking (current and longest)
- 9 unlockable achievements
- Focus tracking with star ratings
- Category-based meditation organization
- Color-coded UI (green theme: #00B894)

#### Data Models:
```dart
class MeditationSession {
  final int id;
  final String name;
  final int durationMinutes;
  final DateTime date;
  final String category;
  final int focusRating;         // 1-5 stars
}

class MindfulnessStats {
  final int totalSessions;
  final int totalMinutes;
  final int currentStreak;
  final int longestStreak;
  final double averageFocusRating;
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool unlocked;
  final DateTime? unlockedDate;
}
```

#### Providers:
- `meditationSessionsProvider`: List of sessions
- `mindfulnessStatsProvider`: Stats data
- `achievementsProvider`: Achievements list

---

### 5. Anxiety Management Screen
**File**: `lib/screens/mental_health/anxiety_management_screen.dart`

#### Tabs:
- **Track Tab**: Log anxiety episodes (intensity 1-10, trigger, coping technique used)
- **Coping Tab**: 8 coping strategies with descriptions (4-7-8 Breathing, Progressive Relaxation, Grounding, Cold Water, Exercise, Journaling, Affirmations, Compassion)
- **Safety Tab**: Emergency contacts, personal warning signs, coping skills, support network

#### Key Features:
- Anxiety intensity slider (1-10)
- Trigger documentation
- Coping strategy selection and tracking
- Emergency contact information (Crisis Line, National Suicide Prevention, 911)
- Personal safety plan section
- Warning signs customization
- Support network management
- Emergency SOS button on floating action button
- Color-coded UI (cyan theme: #00D2D3)

#### Data Models:
```dart
class AnxietyLog {
  final int id;
  final int intensity;           // 1-10
  final String trigger;
  final String? copingTechnique;
  final DateTime date;
  final String? notes;
}

class CopingStrategy {
  final int id;
  final String name;
  final String description;
  final String icon;
  final bool used;
}

class SafetyPlan {
  final int id;
  final String warningSign;
  final List<String> copingSkills;
  final List<String> supportPeople;
  final String crisisNumber;
  final String crisisService;
}
```

#### Providers:
- `anxietyLogsProvider`: List of anxiety entries
- `copingStrategiesProvider`: Available coping strategies
- `safetyPlanProvider`: Personal safety plan

---

### 6. Wellness Dashboard Screen
**File**: `lib/screens/mental_health/wellness_screen.dart`

#### Tabs:
- **Today Tab**: Daily check-in (mood, energy, stress sliders), today's wellness metrics, completed activities
- **Scores Tab**: Overall wellness score (0-100), category scores, weekly trend visualization
- **Goals Tab**: Goal progress summary, active goals with completion percentage, goal details

#### Key Features:
- Daily check-in with 3 sliders (mood, energy, stress - 0-10)
- 4 wellness metrics display (Mood, Energy, Stress, Sleep)
- Activity tracking with tag-based system
- Overall wellness score (0-100 scale)
- 5 category scores with progress bars
- Weekly trend chart
- 5 active goals with progress tracking
- Goal completion percentage calculation
- Add new goal functionality
- Color-coded UI (orange theme: #FFB347)

#### Data Models:
```dart
class DailyCheckin {
  final int id;
  final int mood;                // 0-10
  final int energy;              // 0-10
  final int stress;              // 0-10
  final String sleep;
  final List<String> activities;
  final String? notes;
  final DateTime date;
}

class WellnessScore {
  final double overallScore;     // 0-100
  final double moodScore;        // 0-10
  final double energyScore;      // 0-10
  final double stressScore;      // 0-10
  final double sleepScore;       // 0-10
  final String trend;
}

class WellnessGoal {
  final int id;
  final String title;
  final String category;
  final int progressPercent;     // 0-100
  final String frequency;
  final bool completed;
}
```

#### Providers:
- `dailyCheckinProvider`: List of daily check-ins
- `wellnessScoreProvider`: Current wellness scores
- `goalsProvider`: List of wellness goals

---

## Master Dashboard

**File**: `lib/screens/mental_health_dashboard.dart`

The master dashboard combines all 6 screens with bottom navigation:

```dart
class MentalHealthDashboard extends ConsumerWidget {
  // 6-tab bottom navigation
  // Screens: Stress → Mood → Sleep → Mindfulness → Anxiety → Wellness
}
```

#### Navigation:
- Bottom tab bar with 6 items
- IndexedStack for efficient screen switching
- Riverpod state provider for current tab

#### Usage:
```dart
// In your main app navigation:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const MentalHealthDashboard(),
  ),
);
```

---

## Installation & Setup

### Step 1: Add Dependencies
Ensure `pubspec.yaml` includes:
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.0
  material_color_utilities: ^0.2.0
```

### Step 2: Import App Colors
Ensure `lib/config/app_colors.dart` defines:
```dart
class AppColors {
  static const Color backgroundColor = Color(0xFF1A1A2E);
  static const Color cardColor = Color(0xFF16213E);
  static const Color borderColor = Color(0xFF2D3E50);
  static const Color textColor = Color(0xFFEAEAEA);
  static const Color secondaryText = Color(0xFF9CA3AF);
}
```

### Step 3: Add Screens to App
In your main app file:
```dart
import 'package:soul_fresh/screens/mental_health_dashboard.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MentalHealthDashboard(),
    );
  }
}
```

---

## UI/UX Standards

### Color Theme
- **Stress**: #6C5CE7 (Purple)
- **Mood**: Various warm tones
- **Sleep**: #6C5CE7 (Purple)
- **Mindfulness**: #00B894 (Green)
- **Anxiety**: #00D2D3 (Cyan)
- **Wellness**: #FFB347 (Orange)

### Component Standards
- **Cards**: Dark background with border
- **Buttons**: Elevated with theme color
- **Inputs**: Text fields with rounded corners
- **Progress**: LinearProgressIndicator with theme color
- **Sliders**: Theme-colored with divisions
- **Icons**: Material icons (24-32px)

### Layout Standards
- All screens: TabBar with 3 tabs minimum
- Padding: 16px standard
- Spacing: 12px/24px standard
- Border radius: 8-12px
- Card corners: 12px

---

## API Integration Checklist

When ready to connect to backend:

- [ ] Create `services/mental_health_api_service.dart`
- [ ] Implement API call methods for each screen
- [ ] Update providers to use `FutureProvider` with API calls
- [ ] Add error handling with try/catch
- [ ] Implement loading states with `AsyncValue`
- [ ] Add retry logic for failed requests
- [ ] Cache data locally with Hive/shared_preferences

Example API service skeleton:
```dart
class MentalHealthApiService {
  // Stress endpoints
  Future<void> logStress(int level, String trigger) async {}
  Future<List<StressLog>> getStressLogs() async {}
  Future<StressAnalytics> getStressAnalytics() async {}

  // Mood endpoints
  Future<void> logMood(int level, String activity) async {}
  Future<List<MoodEntry>> getMoodEntries() async {}
  Future<MoodInsights> getMoodInsights() async {}

  // ... repeat for Sleep, Mindfulness, Anxiety, Wellness
}
```

---

## Testing Checklist

- [ ] All 3 tabs load correctly on each screen
- [ ] Data persists when switching between screens
- [ ] Sliders work smoothly (0-100 range)
- [ ] Time pickers function correctly
- [ ] Calendar view displays properly
- [ ] Charts/trends render without errors
- [ ] Buttons trigger intended actions
- [ ] Bottom navigation switches screens
- [ ] No memory leaks with IndexedStack
- [ ] Theme colors apply consistently
- [ ] Text is readable on all backgrounds
- [ ] Responsive on different screen sizes

---

## Performance Optimization

1. **State Management**: Use `StateProvider` for simple state, upgrade to `FutureProvider` for API calls
2. **Widget Building**: Use `ConsumerStatefulWidget` to reduce rebuilds
3. **List Views**: Always use `shrinkWrap: true` and `physics: NeverScrollableScrollPhysics()` for nested lists
4. **Animations**: Keep transitions smooth with standard durations
5. **Memory**: Clean up `TabController` in `dispose()`

---

## Troubleshooting

### Issue: Tab switches lag
- Check if too many widgets rebuild
- Use `ConsumerStatefulWidget` instead of `Consumer`
- Profile with DevTools

### Issue: Data not persisting
- Ensure provider update is called after state change
- Check if `StateProvider` is being watched correctly
- Verify Riverpod is properly initialized

### Issue: UI not matching theme
- Verify `AppColors` constants match hex values
- Check `activeColor` on all sliders/indicators
- Ensure theme color propagates to nested widgets

---

## Future Enhancements

1. **Notifications**: Push notifications for check-in reminders
2. **Health App Integration**: Sync with Apple Health/Google Fit
3. **AI Insights**: ML-based pattern detection and recommendations
4. **Social Features**: Share achievements with friends
5. **Export Data**: PDF/CSV export of wellness history
6. **Wearable Integration**: Real-time biometric data
7. **Offline Mode**: SQLite cache for offline functionality
8. **Advanced Analytics**: Prediction models for wellness trends

---

## Support & Documentation

For questions or issues:
1. Check backend API documentation at `MENTAL_HEALTH_IMPLEMENTATION_GUIDE.md`
2. Review backend schemas at `backend/app/models/mental_health_tracking.py`
3. Check API endpoints at `backend/app/controllers/mental_health_tracking.py`

---

**Last Updated**: [Current Date]  
**Version**: 1.0.0  
**Status**: Complete & Ready for Integration
