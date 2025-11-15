import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mood_app/features/chat/data/chat_api.dart';
import 'package:mood_app/features/chat/models/chat_message.dart';

final chatConversationProvider =
    StateNotifierProvider<ChatConversationNotifier, List<ChatMessage>>((ref) {
  final chatApi = ref.watch(chatApiProvider);
  return ChatConversationNotifier(chatApi);
});

class ChatConversationNotifier extends StateNotifier<List<ChatMessage>> {
  ChatConversationNotifier(this._chatApi) : super(const []);

  final ChatApi _chatApi;

  Future<void> sendMessage(String messageText) async {
    final trimmed = messageText.trim();
    if (trimmed.isEmpty) {
      return;
    }

    state = [
      ...state,
      ChatMessage(text: trimmed, sender: ChatSender.user),
      const ChatMessage(text: '...', sender: ChatSender.ai, isLoading: true),
    ];

    try {
      final reply = await _chatApi.sendMessage(trimmed);
      _replaceLoadingBubble(
        ChatMessage(text: reply.reply, sender: ChatSender.ai),
      );
    } catch (e, stackTrace) {
      log('Error getting AI reply: $e', error: e, stackTrace: stackTrace);
      _replaceLoadingBubble(
        const ChatMessage(
          text: 'Sorry, something went wrong. Please try again.',
          sender: ChatSender.ai,
          isError: true,
        ),
      );
    }
  }

  void _replaceLoadingBubble(ChatMessage replacement) {
    final updated = List<ChatMessage>.from(state);
    final loadingIndex = updated.lastIndexWhere((message) => message.isLoading);

    if (loadingIndex == -1) {
      state = [...updated, replacement];
      return;
    }

    updated[loadingIndex] = replacement;
    state = updated;
  }
}
