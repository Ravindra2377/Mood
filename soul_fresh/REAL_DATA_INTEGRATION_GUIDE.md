# Real Data Integration Guide

This guide explains how to replace mock data with real data from your backend API.

## 📋 Overview

The app currently uses mock data from `lib/data/appMockData.dart`. To use real data, you need to:

1. Update API client with your backend endpoints
2. Replace mock data providers with real API service providers
3. Update screens to handle loading and error states
4. Test with your backend

---

## 🔧 Step 1: Update API Client

### File: `lib/services/api_client.dart`

Add these methods to your `ApiClient` class:

```dart
// Mood endpoints
@GET('/api/mood/history')
Future<List<Map<String, dynamic>>> getMoodHistory({
  @Query('startDate') String? startDate,
  @Query('endDate') String? endDate,
});

@POST('/api/mood')
Future<void> saveMood(@Body() Map<String, dynamic> moodData);

// Activity endpoints
@GET('/api/activities')
Future<List<Map<String, dynamic>>> getActivities();

@GET('/api/activities/stats')
Future<List<Map<String, dynamic>>> getActivityStats({
  @Query('date') String? date,
});

@GET('/api/activities/physical-state')
Future<Map<String, dynamic>> getPhysicalState({
  @Query('date') String? date,
});

// Content endpoints
@GET('/api/content/quote')
Future<Map<String, dynamic>> getDailyQuote();

@GET('/api/content/items')
Future<List<Map<String, dynamic>>> getContentItems({
  @Query('type') String? type,
  @Query('limit') int? limit,
});

// Journal endpoints
@POST('/api/journal')
Future<void> saveJournalEntry(@Body() Map<String, dynamic> entryData);

@GET('/api/journal/entries')
Future<List<Map<String, dynamic>>> getJournalEntries({
  @Query('startDate') String? startDate,
  @Query('endDate') String? endDate,
  @Query('limit') int? limit,
});

@DELETE('/api/journal/{id}')
Future<void> deleteJournalEntry(@Path('id') String entryId);

// User endpoints
@GET('/api/user/profile')
Future<Map<String, dynamic>> getUserProfile();

@PUT('/api/user/profile')
Future<void> updateUserProfile(@Body() Map<String, dynamic> profileData);
```

After adding these methods, run code generation:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 🔄 Step 2: Replace Mock Data with Real Data

### Services Created

I've created the following service files that are ready to use:

1. **`lib/services/mood_service.dart`** - Mood tracking API calls
2. **`lib/services/activity_service.dart`** - Activities and physical state API calls
3. **`lib/services/content_service.dart`** - Quotes and content items API calls
4. **`lib/services/journal_service.dart`** - Journal entries API calls
5. **`lib/services/user_service.dart`** - User profile API calls

### Update Screens to Use Real Data

#### Example: Home Screen with Real Data

**File: `lib/screens/enhanced_home_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/ui_state.dart';
import '../services/activity_service.dart';
import '../services/user_service.dart';
import '../widgets/mood_selector.dart';
import '../widgets/time_filter_pills.dart';
import '../widgets/activity_card.dart';

class EnhancedHomeScreen extends ConsumerWidget {
  static const route = '/enhanced-home';

  const EnhancedHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gradient = Theme.of(context).extension<SoulGradients>()?.pastel ??
        const LinearGradient(colors: [Colors.blue, Colors.teal]);
    
    // Watch real data providers
    final userProfileAsync = ref.watch(userProfileProvider);
    final activitiesAsync = ref.watch(activitiesProvider);
    final selectedMood = ref.watch(selectedMoodProvider);
    final selectedFilter = ref.watch(timeFilterProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with real user data
                userProfileAsync.when(
                  data: (profile) => Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(
                          profile['avatarUrl'] ?? 'https://i.pravatar.cc/150?img=1',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi, ${profile['name'] ?? 'User'}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Text(
                              'How are you doing today?',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications_outlined),
                      ),
                    ],
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Error: $error'),
                ),
                const SizedBox(height: 20),
                
                // Time filter pills
                TimeFilterPills(
                  selectedFilter: selectedFilter,
                  onFilterSelected: (filter) {
                    ref.read(timeFilterProvider.notifier).state = filter;
                  },
                ),
                const SizedBox(height: 16),
                
                // Search bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      border: InputBorder.none,
                      icon: Icon(Icons.search, size: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Daily mood section
                const Text(
                  'Daily mood',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                MoodSelector(
                  selectedMood: selectedMood,
                  onMoodSelected: (mood) async {
                    ref.read(selectedMoodProvider.notifier).state = mood;
                    // Save mood to backend
                    try {
                      final moodService = ref.read(moodServiceProvider);
                      await moodService.saveMood(
                        mood: mood,
                        value: _getMoodValue(mood),
                      );
                    } catch (e) {
                      // Handle error
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to save mood: $e')),
                      );
                    }
                  },
                ),
                const SizedBox(height: 24),
                
                // Activities section with real data
                const Text(
                  'Activities',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                activitiesAsync.when(
                  data: (activities) => SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        final activity = activities[index];
                        return ActivityCard(
                          activity: activity,
                          onTap: () {
                            // Navigate based on activity type
                          },
                        );
                      },
                    ),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Text('Error loading activities: $error'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _getMoodValue(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.angry:
        return 2;
      case MoodLevel.sad:
        return 4;
      case MoodLevel.neutral:
        return 6;
      case MoodLevel.happy:
        return 8;
      case MoodLevel.veryHappy:
        return 10;
    }
  }
}
```

---

## 📊 Step 3: Update Other Screens

### Activities Screen

Replace `AppMockData.activityStats` with `ref.watch(activityStatsProvider)`:

```dart
final activityStatsAsync = ref.watch(activityStatsProvider);
final physicalStateAsync = ref.watch(physicalStateProvider);

// Use .when() to handle loading/error states
activityStatsAsync.when(
  data: (stats) => /* Build UI with stats */,
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);
```

### Resources Screen

Replace `AppMockData.quote` and `AppMockData.contentItems`:

```dart
final quoteAsync = ref.watch(dailyQuoteProvider);
final contentItemsAsync = ref.watch(contentItemsProvider);

// Use .when() for each provider
```

### Expression Screen

Save journal entry to backend:

```dart
final journalService = ref.read(journalServiceProvider);
await journalService.saveJournalEntry(text: _textController.text);
```

---

## 🔐 Step 4: Backend API Requirements

Your backend should provide these endpoints:

### Mood Endpoints
- `GET /api/mood/history` - Get mood history
- `POST /api/mood` - Save new mood entry

### Activity Endpoints
- `GET /api/activities` - Get user's activities
- `GET /api/activities/stats` - Get activity statistics
- `GET /api/activities/physical-state` - Get physical state data

### Content Endpoints
- `GET /api/content/quote` - Get daily motivational quote
- `GET /api/content/items` - Get content items (articles/videos)

### Journal Endpoints
- `POST /api/journal` - Save journal entry
- `GET /api/journal/entries` - Get journal entries
- `DELETE /api/journal/{id}` - Delete journal entry

### User Endpoints
- `GET /api/user/profile` - Get user profile
- `PUT /api/user/profile` - Update user profile

---

## 🧪 Step 5: Testing

### Test with Mock Backend First

1. Set up a local mock server or use tools like:
   - **Postman Mock Server**
   - **JSON Server** (`npm install -g json-server`)
   - **MockAPI.io**

2. Update `lib/state/runtime_config.dart` with your test server URL

3. Test each screen individually

### Example JSON Responses

**Mood History Response:**
```json
[
  {
    "date": "2024-01-22T10:00:00Z",
    "mood": "happy",
    "value": 8
  }
]
```

**Activities Response:**
```json
[
  {
    "id": "act-1",
    "type": "yoga",
    "title": "Yoga",
    "color": "#E8B4F0"
  }
]
```

**Physical State Response:**
```json
{
  "percentage": 0.78,
  "sleepGoal": "8h Target",
  "lastNight": "7.5h Achieved",
  "deficit": "1.5 Missing"
}
```

---

## 🚀 Step 6: Gradual Migration

You can migrate gradually by:

1. **Start with one feature** (e.g., mood tracking)
2. **Keep mock data as fallback**:

```dart
final moodHistoryProvider = FutureProvider<List<MoodHistoryItem>>((ref) async {
  try {
    final moodService = ref.watch(moodServiceProvider);
    return await moodService.getMoodHistory();
  } catch (e) {
    // Fallback to mock data
    return AppMockData.moodHistory;
  }
});
```

3. **Add feature flags**:

```dart
// lib/config/feature_flags.dart
class FeatureFlags {
  static const bool useMockData = false; // Toggle this
}

// In provider
final activitiesProvider = FutureProvider<List<Activity>>((ref) async {
  if (FeatureFlags.useMockData) {
    return AppMockData.activities;
  }
  
  final activityService = ref.watch(activityServiceProvider);
  return await activityService.getActivities();
});
```

---

## 🔍 Debugging Tips

1. **Check API responses** in logs:
```dart
print('API Response: $response');
```

2. **Use Dio interceptors** for logging:
```dart
dio.interceptors.add(LogInterceptor(
  requestBody: true,
  responseBody: true,
));
```

3. **Handle errors gracefully**:
```dart
try {
  final data = await apiCall();
  return data;
} on DioException catch (e) {
  if (e.response?.statusCode == 401) {
    // Handle unauthorized
  }
  throw Exception('API Error: ${e.message}');
}
```

---

## 📝 Checklist

- [ ] Update `api_client.dart` with all endpoints
- [ ] Run code generation for Retrofit
- [ ] Test API endpoints with Postman/curl
- [ ] Update screens to use real data providers
- [ ] Add loading and error states to all screens
- [ ] Test with real backend
- [ ] Add error handling and retry logic
- [ ] Update authentication flow
- [ ] Test offline functionality
- [ ] Add data caching with Hive

---

## 💡 Best Practices

1. **Always handle loading and error states**
2. **Cache data locally** for offline access
3. **Use refresh indicators** for pull-to-refresh
4. **Add retry mechanisms** for failed requests
5. **Show meaningful error messages** to users
6. **Log errors** for debugging
7. **Test with slow network** conditions
8. **Implement pagination** for large lists
9. **Add request timeouts**
10. **Validate data** before displaying

---

## 📚 Additional Resources

- [Riverpod Documentation](https://riverpod.dev/)
- [Retrofit Documentation](https://pub.dev/packages/retrofit)
- [Dio Documentation](https://pub.dev/packages/dio)
- [Flutter Error Handling](https://docs.flutter.dev/testing/errors)

---

## 🆘 Need Help?

If you encounter issues:

1. Check the console logs for errors
2. Verify API endpoint URLs
3. Check authentication tokens
4. Test API endpoints independently
5. Review network requests in DevTools

---

**Happy Coding! 🎉**