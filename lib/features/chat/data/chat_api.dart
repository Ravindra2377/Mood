import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mood_app/core/network/http_client_provider.dart';

final chatApiProvider = Provider<ChatApi>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return ChatApi(httpClient);
});

class ChatReply {
  final String reply;

  const ChatReply({required this.reply});

  factory ChatReply.fromJson(Map<String, dynamic> json) {
    return ChatReply(
      reply: json['reply'] as String? ?? 'Sorry, I had trouble understanding that.',
    );
  }
}

class ChatApi {
  ChatApi(this._httpClient);

  final http.Client _httpClient;

  Future<ChatReply> sendMessage(String message) async {
    try {
      final _ = _httpClient; // Keep provider dependency wired until network calls are enabled.
      // Placeholder response until backend integration lands.
      await Future<void>.delayed(const Duration(milliseconds: 350));
      return ChatReply(reply: 'I hear you. Tell me more about "$message".');
    } catch (e, stackTrace) {
      log('Unexpected error in ChatApi: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
