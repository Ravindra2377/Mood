import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_models.dart';
import '../state/app_state.dart';
import 'api_client.dart';

/// Service for mood-related API calls
class MoodService {
  final ApiClient _apiClient;

  MoodService(this._apiClient);

  /// Fetch mood history for the current user
  Future<List<MoodHistoryItem>> getMoodHistory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Replace with your actual API endpoint
  final response = await (_apiClient as dynamic).getMoodHistory(
        startDate: startDate?.toIso8601String(),
        endDate: endDate?.toIso8601String(),
      );
      
      // Parse response and convert to MoodHistoryItem list
      return response.map((item) => MoodHistoryItem(
        date: DateTime.parse(item['date']),
        mood: _parseMoodLevel(item['mood']),
        value: item['value'] as int,
      )).toList();
    } catch (e) {
      throw Exception('Failed to fetch mood history: $e');
    }
  }

  /// Save a new mood entry
  Future<void> saveMood({
    required MoodLevel mood,
    required int value,
    DateTime? timestamp,
  }) async {
    try {
  await (_apiClient as dynamic).saveMood({
        'mood': mood.toString().split('.').last,
        'value': value,
        'timestamp': (timestamp ?? DateTime.now()).toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to save mood: $e');
    }
  }

  MoodLevel _parseMoodLevel(String mood) {
    switch (mood.toLowerCase()) {
      case 'angry':
        return MoodLevel.angry;
      case 'sad':
        return MoodLevel.sad;
      case 'neutral':
        return MoodLevel.neutral;
      case 'happy':
        return MoodLevel.happy;
      case 'veryhappy':
      case 'very_happy':
        return MoodLevel.veryHappy;
      default:
        return MoodLevel.neutral;
    }
  }
}

/// Provider for MoodService
final moodServiceProvider = Provider<MoodService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MoodService(apiClient);
});

/// Provider for mood history
final moodHistoryProvider = FutureProvider<List<MoodHistoryItem>>((ref) async {
  final moodService = ref.watch(moodServiceProvider);
  return await moodService.getMoodHistory();
});