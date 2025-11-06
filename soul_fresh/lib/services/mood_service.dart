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
      // Use the typed ApiClient method instead of dynamic cast
      final response = await _apiClient.listMoods(
        fromIso: startDate?.toIso8601String(),
        toIso: endDate?.toIso8601String(),
      );
      
      // Parse response and convert to MoodHistoryItem list
      return response.map((item) => MoodHistoryItem(
        date: item.createdAt,
        mood: _scoreToMoodLevel(item.score),
        value: item.score,
      ),).toList();
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
      // Use the typed ApiClient method
      await _apiClient.createMood(CreateMoodRequest(
        score: value,
      ),);
    } catch (e) {
      throw Exception('Failed to save mood: $e');
    }
  }

  /// Convert score (1-10) to MoodLevel enum
  MoodLevel _scoreToMoodLevel(int score) {
    if (score <= 2) return MoodLevel.angry;
    if (score <= 4) return MoodLevel.sad;
    if (score <= 6) return MoodLevel.neutral;
    if (score <= 8) return MoodLevel.happy;
    return MoodLevel.veryHappy;
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
