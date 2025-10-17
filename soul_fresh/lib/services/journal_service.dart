import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';

/// Service for journal-related API calls
class JournalService {
  final ApiClient _apiClient;

  JournalService(this._apiClient);

  /// Save journal entry
  Future<void> saveJournalEntry({
    required String text,
    DateTime? timestamp,
  }) async {
    try {
      await _apiClient.saveJournalEntry({
        'text': text,
        'timestamp': (timestamp ?? DateTime.now()).toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to save journal entry: $e');
    }
  }

  /// Fetch journal entries
  Future<List<Map<String, dynamic>>> getJournalEntries({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      return await _apiClient.getJournalEntries(
        startDate: startDate?.toIso8601String(),
        endDate: endDate?.toIso8601String(),
        limit: limit,
      );
    } catch (e) {
      throw Exception('Failed to fetch journal entries: $e');
    }
  }

  /// Delete journal entry
  Future<void> deleteJournalEntry(String entryId) async {
    try {
      await _apiClient.deleteJournalEntry(entryId);
    } catch (e) {
      throw Exception('Failed to delete journal entry: $e');
    }
  }
}

/// Provider for JournalService
final journalServiceProvider = Provider<JournalService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return JournalService(apiClient);
});

/// Provider for journal entries
final journalEntriesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final journalService = ref.watch(journalServiceProvider);
  return await journalService.getJournalEntries();
});