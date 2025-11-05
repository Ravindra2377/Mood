import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_models.dart';
import '../state/app_state.dart';
import 'api_client.dart';

/// Service for content and resources API calls
class ContentService {
  final ApiClient _apiClient;

  ContentService(this._apiClient);

  /// Fetch daily quote
  Future<Quote> getDailyQuote() async {
    try {
  final response = await (_apiClient as dynamic).getDailyQuote();
      
      return Quote(
        text: response['text'] as String,
        author: response['author'] as String,
      );
    } catch (e) {
      throw Exception('Failed to fetch daily quote: $e');
    }
  }

  /// Fetch content items (articles, videos, etc.)
  Future<List<ContentItem>> getContentItems({
    ContentType? type,
    int? limit,
  }) async {
    try {
  final response = await (_apiClient as dynamic).getContentItems(
        type: type?.toString().split('.').last,
        limit: limit,
      );
      
      return response.map((item) => ContentItem(
        id: item['id'] as String,
        type: _parseContentType(item['type']),
        title: item['title'] as String,
        duration: item['duration'] as String,
        thumbnail: item['thumbnail'] as String,
      ),).toList();
    } catch (e) {
      throw Exception('Failed to fetch content items: $e');
    }
  }

  ContentType _parseContentType(String type) {
    switch (type.toLowerCase()) {
      case 'article':
        return ContentType.article;
      case 'video':
        return ContentType.video;
      case 'audio':
        return ContentType.audio;
      default:
        return ContentType.article;
    }
  }
}

/// Provider for ContentService
final contentServiceProvider = Provider<ContentService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ContentService(apiClient);
});

/// Provider for daily quote
final dailyQuoteProvider = FutureProvider<Quote>((ref) async {
  final contentService = ref.watch(contentServiceProvider);
  return await contentService.getDailyQuote();
});

/// Provider for content items
final contentItemsProvider = FutureProvider<List<ContentItem>>((ref) async {
  final contentService = ref.watch(contentServiceProvider);
  return await contentService.getContentItems();
});

