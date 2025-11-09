import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_models.dart';
import '../state/app_state.dart';
import 'api_client.dart';

/// Service for activity-related API calls
class ActivityService {
  final ApiClient _apiClient;

  ActivityService(this._apiClient);

  /// Fetch user's activities
  Future<List<Activity>> getActivities() async {
    try {
      final response = await (_apiClient as dynamic).getActivities();

      final data = response as List<dynamic>;
      return data.map((item) {
        final activityData = item as Map<String, dynamic>;
        return Activity(
          id: activityData['id'] as String,
          type: _parseActivityType(activityData['type'] as String),
          title: activityData['title'] as String,
          color: Color(
            int.parse(
              (activityData['color'] as String).replaceFirst('#', '0xFF'),
            ),
          ),
          icon: _getIconForType(activityData['type'] as String),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch activities: $e');
    }
  }

  /// Fetch activity statistics
  Future<List<ActivityStat>> getActivityStats({DateTime? date}) async {
    try {
      final response = await (_apiClient as dynamic).getActivityStats(
        date: date?.toIso8601String(),
      );

      final data = response as List<dynamic>;
      return data.map((item) {
        final statData = item as Map<String, dynamic>;
        return ActivityStat(
          id: statData['id'] as String,
          title: statData['title'] as String,
          value: statData['value'] as String,
          color: Color(
            int.parse(
              (statData['color'] as String).replaceFirst('#', '0xFF'),
            ),
          ),
          icon: _getIconForStat(statData['type'] as String),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch activity stats: $e');
    }
  }

  /// Fetch physical state data
  Future<PhysicalState> getPhysicalState({DateTime? date}) async {
    try {
      final response = await (_apiClient as dynamic).getPhysicalState(
        date: date?.toIso8601String(),
      );

      final data = response as Map<String, dynamic>;
      return PhysicalState(
        percentage: (data['percentage'] as num).toDouble(),
        sleepGoal: data['sleepGoal'] as String,
        lastNight: data['lastNight'] as String,
        deficit: data['deficit'] as String,
      );
    } catch (e) {
      throw Exception('Failed to fetch physical state: $e');
    }
  }

  ActivityType _parseActivityType(String type) {
    switch (type.toLowerCase()) {
      case 'yoga':
        return ActivityType.yoga;
      case 'journal':
        return ActivityType.journal;
      case 'exercises':
        return ActivityType.exercises;
      case 'practices':
        return ActivityType.practices;
      case 'meditation':
        return ActivityType.meditation;
      default:
        return ActivityType.exercises;
    }
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'yoga':
        return Icons.self_improvement;
      case 'journal':
        return Icons.menu_book;
      case 'exercises':
        return Icons.auto_awesome;
      case 'practices':
        return Icons.spa;
      case 'meditation':
        return Icons.self_improvement;
      default:
        return Icons.fitness_center;
    }
  }

  IconData _getIconForStat(String type) {
    switch (type.toLowerCase()) {
      case 'sleep':
        return Icons.bedtime;
      case 'mood':
        return Icons.sentiment_satisfied;
      case 'active':
        return Icons.directions_run;
      default:
        return Icons.analytics;
    }
  }
}

/// Provider for ActivityService
final activityServiceProvider = Provider<ActivityService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ActivityService(apiClient);
});

/// Provider for activities list
final activitiesProvider = FutureProvider<List<Activity>>((ref) async {
  final activityService = ref.watch(activityServiceProvider);
  return await activityService.getActivities();
});

/// Provider for activity stats
final activityStatsProvider = FutureProvider<List<ActivityStat>>((ref) async {
  final activityService = ref.watch(activityServiceProvider);
  return await activityService.getActivityStats();
});

/// Provider for physical state
final physicalStateProvider = FutureProvider<PhysicalState>((ref) async {
  final activityService = ref.watch(activityServiceProvider);
  return await activityService.getPhysicalState();
});
