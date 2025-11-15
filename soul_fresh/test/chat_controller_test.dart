import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul/features/self_help/controllers/chat_controller.dart';
import 'package:soul/models/chat_models.dart';
import 'package:soul/services/chat_api_service.dart';

/// Fake streaming service to simulate tokens followed by completion
class FakeChatApiService extends ChatApiService {
  FakeChatApiService() : super(baseUrl: 'http://localhost');

  @override
  Stream<ChatStreamChunk> sendMessage({
    required String message,
    String? sessionId,
    bool includeContext = true,
  }) async* {
    // Simulate a new session id returned early
    yield const ChatStreamChunk(sessionId: 'session-1');
    // Simulate streaming tokens
    yield const ChatStreamChunk(token: 'Hello');
    yield const ChatStreamChunk(token: ', how are');
    yield const ChatStreamChunk(token: ' you?');
    // Mark done
    yield const ChatStreamChunk(done: true);
  }
}

class ErrorChatApiService extends ChatApiService {
  ErrorChatApiService() : super(baseUrl: 'http://localhost');
  @override
  Stream<ChatStreamChunk> sendMessage({
    required String message,
    String? sessionId,
    bool includeContext = true,
  }) async* {
    // Return early session id
    yield const ChatStreamChunk(sessionId: 'session-err');
    // Emit an error chunk
    yield const ChatStreamChunk(error: 'Internal error', done: true);
  }
}

void main() {
  group('ChatController.sendMessage', () {
    test('streams tokens and finalizes assistant message', () async {
      final container = ProviderContainer(
        overrides: [
          chatApiServiceProvider.overrideWithValue(FakeChatApiService()),
        ],
      );

      final controller = container.read(chatControllerProvider.notifier);

      await controller.sendMessage('Hi');

      final state = container.read(chatControllerProvider);
      expect(state.currentSessionId, equals('session-1'));
      expect(state.isStreaming, isFalse);
      expect(state.messages.length, equals(2)); // user + assistant
      final user = state.messages.first;
      final assistant = state.messages.last;
      expect(user.role, MessageRole.user);
      expect(assistant.role, MessageRole.assistant);
      expect(assistant.content, equals('Hello, how are you?'));
      expect(assistant.isStreaming, isFalse);
      expect(state.error, isNull);
    });

    test('handles error chunk and sets error state', () async {
      final container = ProviderContainer(
        overrides: [
          chatApiServiceProvider.overrideWithValue(ErrorChatApiService()),
        ],
      );

      final controller = container.read(chatControllerProvider.notifier);
      await controller.sendMessage('Hi');

      final state = container.read(chatControllerProvider);
      expect(state.currentSessionId, equals('session-err'));
      expect(state.isStreaming, isFalse);
      expect(state.error, isNotNull);
      expect(state.messages.last.content, contains('Internal error'));
    });

    test('ignores empty message', () async {
      final container = ProviderContainer(
        overrides: [
          chatApiServiceProvider.overrideWithValue(FakeChatApiService()),
        ],
      );
      final controller = container.read(chatControllerProvider.notifier);
      await controller.sendMessage('   ');
      final state = container.read(chatControllerProvider);
      expect(state.messages, isEmpty);
    });
  });
}
