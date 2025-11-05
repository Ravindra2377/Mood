/// Riverpod state management for AI chat functionality.
/// Handles message streaming, session management, and crisis responses.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soul/models/chat_models.dart';
import 'package:soul/services/chat_api_service.dart';

final chatControllerProvider =
    StateNotifierProvider<ChatController, ChatState>((ref) {
  return ChatController(ref.watch(chatApiServiceProvider));
});

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;
  final String? currentSessionId;
  final bool isStreaming;
  final CrisisResponse? crisisResponse;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.currentSessionId,
    this.isStreaming = false,
    this.crisisResponse,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    String? currentSessionId,
    bool? isStreaming,
    CrisisResponse? crisisResponse,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentSessionId: currentSessionId ?? this.currentSessionId,
      isStreaming: isStreaming ?? this.isStreaming,
      crisisResponse: crisisResponse,
    );
  }
}

class ChatController extends StateNotifier<ChatState> {
  final ChatApiService _apiService;

  ChatController(this._apiService) : super(ChatState());

  /// Send a message and stream the response
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    final sessionIdForRequest =
        (state.currentSessionId != null && state.currentSessionId!.isNotEmpty)
            ? state.currentSessionId
            : null;

    String generateMessageId(String prefix) =>
        '$prefix-${DateTime.now().microsecondsSinceEpoch}-${state.messages.length}';

    // Add user message immediately
    final userMessage = ChatMessage(
      id: generateMessageId('user'),
      sessionId: state.currentSessionId ?? '',
      role: MessageRole.user,
      content: message,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isStreaming: true,
    );

    // Create placeholder for assistant message
  final assistantMessageId = generateMessageId('assistant');
    final assistantMessage = ChatMessage(
      id: assistantMessageId,
      sessionId: state.currentSessionId ?? '',
      role: MessageRole.assistant,
      content: '',
      createdAt: DateTime.now(),
      isStreaming: true,
    );

    state = state.copyWith(
      messages: [...state.messages, assistantMessage],
    );

    try {
      String accumulatedContent = '';

      await for (final chunk in _apiService.sendMessage(
        message: message,
        sessionId: sessionIdForRequest,
      )) {
        // Attach session id when backend sends it back (first response)
        if (chunk.sessionId != null && chunk.sessionId!.isNotEmpty) {
          final updatedMessagesWithSession = state.messages.map((msg) {
            if (msg.sessionId.isEmpty) {
              return msg.copyWith(sessionId: chunk.sessionId);
            }
            return msg;
          }).toList();

          state = state.copyWith(
            currentSessionId: chunk.sessionId,
            messages: updatedMessagesWithSession,
          );
        }

        if (chunk.isCrisis && chunk.crisis != null) {
          state = state.copyWith(
            crisisResponse: chunk.crisis,
            isStreaming: false,
            messages: state.messages
                .where((m) => m.id != assistantMessageId)
                .toList(),
          );
          return;
        }

        if (chunk.hasError) {
          final failureMessage = chunk.error ?? 'Unable to respond right now. Please try again later.';
          final messagesWithError = state.messages.map((msg) {
            if (msg.id == assistantMessageId) {
              return msg.copyWith(
                content: failureMessage,
                isStreaming: false,
              );
            }
            return msg;
          }).toList();

          state = state.copyWith(
            error: failureMessage,
            messages: messagesWithError,
            isStreaming: false,
          );
          return;
        }

        if (chunk.hasToken) {
          accumulatedContent += chunk.token!;

          // Update the assistant message with accumulated content
          final updatedMessages = state.messages.map((msg) {
            if (msg.id == assistantMessageId) {
              return msg.copyWith(
                content: accumulatedContent,
                isStreaming: true,
              );
            }
            return msg;
          }).toList();

          state = state.copyWith(messages: updatedMessages);
        }
      }

      // Mark streaming as complete
      final finalMessages = state.messages.map((msg) {
        if (msg.id == assistantMessageId) {
          return msg.copyWith(isStreaming: false);
        }
        return msg;
      }).toList();

      state = state.copyWith(
        messages: finalMessages,
        isStreaming: false,
      );
    } catch (e) {
      final fallback = 'Failed to send message: ${e.toString()}';
      final messagesWithError = state.messages.map((msg) {
        if (msg.id == assistantMessageId) {
          return msg.copyWith(
            content: fallback,
            isStreaming: false,
          );
        }
        return msg;
      }).toList();

      state = state.copyWith(
        error: fallback,
        isStreaming: false,
        messages: messagesWithError,
      );
    }
  }

  /// Load chat history for a session
  Future<void> loadHistory(String sessionId) async {
    state = state.copyWith(isLoading: true);

    try {
      final messages = await _apiService.getSessionMessages(sessionId);
      state = state.copyWith(
        messages: messages,
        currentSessionId: sessionId,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load history: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  /// Clear crisis response
  void clearCrisisResponse() {
    state = state.copyWith();
  }

  /// Start a new chat session
  void newSession() {
    state = ChatState();
  }

  /// Load list of sessions
  Future<List<ChatSession>> loadSessions({int limit = 10}) async {
    try {
      return await _apiService.getSessions(limit: limit);
    } catch (e) {
      state = state.copyWith(error: 'Failed to load sessions: ${e.toString()}');
      rethrow;
    }
  }

  /// Delete a session
  Future<void> deleteSession(String sessionId) async {
    try {
      await _apiService.deleteSession(sessionId);
      // If it's the current session, start a new one
      if (state.currentSessionId == sessionId) {
        newSession();
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete session: ${e.toString()}');
      rethrow;
    }
  }
}

// Bonus: Provider for sessions list
final chatSessionsProvider = FutureProvider.autoDispose<List<ChatSession>>((ref) async {
  final controller = ref.watch(chatControllerProvider.notifier);
  return controller.loadSessions(limit: 20);
});

// Bonus: Provider for session messages (given a sessionId)
final sessionMessagesProvider =
    FutureProvider.family.autoDispose<List<ChatMessage>, String>((ref, sessionId) async {
  final apiService = ref.watch(chatApiServiceProvider);
  return apiService.getSessionMessages(sessionId);
});
