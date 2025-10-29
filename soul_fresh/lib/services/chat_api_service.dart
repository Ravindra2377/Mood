/// API service for chat interactions with the backend.
/// Handles streaming responses and session management.

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_models.dart';
import '../core/config.dart';
import 'auth_service.dart';
import 'secure_storage_service.dart';

final chatApiServiceProvider = Provider((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  final authService = AuthService(storage);
  return ChatApiService(
    baseUrl: AppConfig.apiBaseUrl,
    authService: authService,
  );
});

class ChatStreamChunk {
  final String? token;
  final bool done;
  final String? sessionId;
  final CrisisResponse? crisis;
  final String? error;

  const ChatStreamChunk({
    this.token,
    this.done = false,
    this.sessionId,
    this.crisis,
    this.error,
  });

  bool get hasToken => (token ?? '').isNotEmpty;
  bool get hasError => (error ?? '').isNotEmpty;
  bool get isCrisis => crisis != null;
}

class ChatApiService {
  final String baseUrl;
  final AuthService _authService;

  ChatApiService({
    String? baseUrl,
    AuthService? authService,
  })  : baseUrl = baseUrl ?? AppConfig.apiBaseUrl,
        _authService = authService ?? AuthService(SecureStorageService());

  /// Send message and stream response as tokens
  Stream<ChatStreamChunk> sendMessage({
    required String message,
    String? sessionId,
    bool includeContext = true,
  }) async* {
    try {
      final token = await _authService.getAccessToken();

      final requestBody = jsonEncode({
        'message': message,
        'session_id': sessionId,
        'include_context': includeContext,
      });

      final request = http.Request(
        'POST',
        Uri.parse('$baseUrl/chat/interactive'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream',
      });

      request.body = requestBody;

      final streamedResponse = await request.send();

      if (streamedResponse.statusCode != 200) {
        final errorBody = await streamedResponse.stream.bytesToString();
        throw Exception(
          'Failed to send message: ${streamedResponse.statusCode} ${errorBody.isNotEmpty ? '- $errorBody' : ''}',
        );
      }

      // Parse SSE stream with buffering to handle partial chunks
      var buffer = '';
      await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
        buffer += chunk.replaceAll('\r\n', '\n');

        while (buffer.contains('\n\n')) {
          final separatorIndex = buffer.indexOf('\n\n');
          final rawEvent = buffer.substring(0, separatorIndex);
          buffer = buffer.substring(separatorIndex + 2);

          if (rawEvent.isEmpty) {
            continue;
          }

          final dataLines = rawEvent
              .split('\n')
              .where((line) => line.startsWith('data:'))
              .map((line) => line.substring(5).trimLeft())
              .join();

          if (dataLines.isEmpty) {
            continue;
          }

          try {
            final decoded = jsonDecode(dataLines) as Map<String, dynamic>;

            if (decoded.containsKey('is_crisis')) {
              yield ChatStreamChunk(
                crisis: CrisisResponse.fromJson(decoded),
                done: true,
              );
              return;
            }

            if (decoded.containsKey('error')) {
              yield ChatStreamChunk(
                error: decoded['error']?.toString(),
                done: decoded['done'] == true,
                sessionId: decoded['session_id']?.toString(),
              );
              if (decoded['done'] == true) {
                return;
              }
              continue;
            }

            if (decoded['done'] == true) {
              yield ChatStreamChunk(
                done: true,
                sessionId: decoded['session_id']?.toString(),
              );
              return;
            }

            final token = decoded['token'] as String? ?? '';
            if (token.isEmpty) {
              continue;
            }

            yield ChatStreamChunk(token: token);
          } catch (e) {
            yield ChatStreamChunk(error: 'Stream decode error: ${e.toString()}');
            return;
          }
        }
      }

      // Handle any remaining buffer (non-SSE JSON responses like crisis detection)
      if (buffer.trim().isNotEmpty) {
        try {
          final decoded = jsonDecode(buffer.trim()) as Map<String, dynamic>;

          if (decoded.containsKey('is_crisis')) {
            yield ChatStreamChunk(
              crisis: CrisisResponse.fromJson(decoded),
              done: true,
            );
            return;
          }

          if (decoded.containsKey('error')) {
            yield ChatStreamChunk(
              error: decoded['error']?.toString(),
              done: decoded['done'] == true,
              sessionId: decoded['session_id']?.toString(),
            );
            return;
          }
        } catch (e) {
          yield ChatStreamChunk(error: 'Stream decode error: ${e.toString()}');
        }
      }
    } catch (e) {
      throw Exception('Stream error: ${e.toString()}');
    }
  }

  /// Get list of user's chat sessions
  Future<List<ChatSession>> getSessions({int limit = 10}) async {
    try {
      final token = await _authService.getAccessToken();

      final response = await http.get(
        Uri.parse('$baseUrl/chat/sessions?limit=$limit'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ChatSession.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load sessions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading sessions: ${e.toString()}');
    }
  }

  /// Get all messages in a specific session
  Future<List<ChatMessage>> getSessionMessages(String sessionId) async {
    try {
      final token = await _authService.getAccessToken();

      final response = await http.get(
        Uri.parse('$baseUrl/chat/sessions/$sessionId/messages'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ChatMessage.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading messages: ${e.toString()}');
    }
  }

  /// Delete a chat session
  Future<void> deleteSession(String sessionId) async {
    try {
      final token = await _authService.getAccessToken();

      final response = await http.delete(
        Uri.parse('$baseUrl/chat/sessions/$sessionId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete session: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting session: ${e.toString()}');
    }
  }
}
