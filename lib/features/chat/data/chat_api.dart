import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soul_fresh/core/network/http_client_provider.dart';

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
  final Dio _httpClient;

  ChatApi(this._httpClient);

  Future<ChatReply> sendMessage(String message) async {
    try {
      final response = await _httpClient.post(
        '/chat',
        data: {'message': message},
      );

      return ChatReply.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e, stackTrace) {
      log(
        'Error sending chat message: ${e.response?.data ?? e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      log('Unexpected error in ChatApi: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
