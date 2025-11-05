import 'dart:developer' as dev;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/feature_flags.dart';
import '../models/app_models.dart';
import '../services/activity_service.dart';
import '../services/content_service.dart';
import '../services/mood_service.dart';
import 'appMockData.dart';

/// Unified data providers that switch between mock and real data
/// based on FeatureFlags.useMockData

/// Provider for activities - switches between mock and real data
final unifiedActivitiesProvider = FutureProvider<List<Activity>>((ref) async {
  if (FeatureFlags.useMockData) {
    // Return mock data
    return AppMockData.activities;
  }
  
  // Fetch from API
  try {
    final activityService = ref.watch(activityServiceProvider);
    return await activityService.getActivities();
  } catch (e) {
    // Fallback to mock data on error
    if (FeatureFlags.enableDebugLogging) {
      dev.log('Error fetching activities, using mock data', error: e);
    }
    return AppMockData.activities;
  }
});

/// Provider for activity stats - switches between mock and real data
final unifiedActivityStatsProvider = FutureProvider<List<ActivityStat>>((ref) async {
  if (FeatureFlags.useMockData) {
    return AppMockData.activityStats;
  }
  
  try {
    final activityService = ref.watch(activityServiceProvider);
    return await activityService.getActivityStats();
  } catch (e) {
    if (FeatureFlags.enableDebugLogging) {
      dev.log('Error fetching activity stats, using mock data', error: e);
    }
    return AppMockData.activityStats;
  }
});

/// Provider for physical state - switches between mock and real data
final unifiedPhysicalStateProvider = FutureProvider<PhysicalState>((ref) async {
  if (FeatureFlags.useMockData) {
    return AppMockData.physicalState;
  }
  
  try {
    final activityService = ref.watch(activityServiceProvider);
    return await activityService.getPhysicalState();
  } catch (e) {
    if (FeatureFlags.enableDebugLogging) {
      dev.log('Error fetching physical state, using mock data', error: e);
    }
    return AppMockData.physicalState;
  }
});

/// Provider for daily quote - switches between mock and real data
final unifiedDailyQuoteProvider = FutureProvider<Quote>((ref) async {
  if (FeatureFlags.useMockData) {
    return AppMockData.quote;
  }
  
  try {
    final contentService = ref.watch(contentServiceProvider);
    return await contentService.getDailyQuote();
  } catch (e) {
    if (FeatureFlags.enableDebugLogging) {
      dev.log('Error fetching daily quote, using mock data', error: e);
    }
    return AppMockData.quote;
  }
});

/// Provider for content items - switches between mock and real data
final unifiedContentItemsProvider = FutureProvider<List<ContentItem>>((ref) async {
  if (FeatureFlags.useMockData) {
    return AppMockData.contentItems;
  }
  
  try {
    final contentService = ref.watch(contentServiceProvider);
    return await contentService.getContentItems();
  } catch (e) {
    if (FeatureFlags.enableDebugLogging) {
      dev.log('Error fetching content items, using mock data', error: e);
    }
    return AppMockData.contentItems;
  }
});

/// Provider for mood history - switches between mock and real data
final unifiedMoodHistoryProvider = FutureProvider<List<MoodHistoryItem>>((ref) async {
  if (FeatureFlags.useMockData) {
    return AppMockData.moodHistory;
  }
  
  try {
    final moodService = ref.watch(moodServiceProvider);
    return await moodService.getMoodHistory();
  } catch (e) {
    if (FeatureFlags.enableDebugLogging) {
      dev.log('Error fetching mood history, using mock data', error: e);
    }
    return AppMockData.moodHistory;
  }
});

/// Provider for calendar week - always returns mock data for now
/// Update this when you have a calendar API endpoint
final unifiedCalendarWeekProvider = Provider<List<CalendarDay>>((ref) {
  return AppMockData.calendarWeek;
});

