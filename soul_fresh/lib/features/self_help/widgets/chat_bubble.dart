/// Chat bubble widget for displaying individual messages.
/// Includes streaming indicator, timestamps, and styling.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:soul/models/chat_models.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isDarkMode;
  final VoidCallback? onTap;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isDarkMode,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final timeFormat = DateFormat('h:mm a');
    final formattedTime = timeFormat.format(message.createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.teal.shade400],
                ),
              ),
              child: const Center(
                child: Text('ðŸ¤–', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _getBubbleColor(context, isUser),
                  borderRadius: BorderRadius.circular(16).copyWith(
                    bottomLeft:
                        isUser ? const Radius.circular(16) : Radius.zero,
                    bottomRight:
                        isUser ? Radius.zero : const Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Message content
                    SelectableText(
                      message.content,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _getTextColor(isUser, isDarkMode),
                          ),
                    ),

                    // Timestamp
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        formattedTime,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: _getTimestampColor(isUser, isDarkMode),
                            ),
                      ),
                    ),

                    // Streaming indicator
                    if (message.isStreaming)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            3,
                            (i) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _getTextColor(isUser, isDarkMode)
                                      .withOpacity(0.6),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.purple, Colors.pink],
                ),
              ),
              child: const Center(
                child: Text('ðŸ‘¤', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getBubbleColor(BuildContext context, bool isUser) {
    if (isUser) {
      return Colors.purple.shade100;
    } else {
      return Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade800
          : Colors.grey.shade100;
    }
  }

  Color _getTextColor(bool isUser, bool isDarkMode) {
    if (isUser) {
      return Colors.purple.shade900;
    } else {
      return isDarkMode ? Colors.white : Colors.black87;
    }
  }

  Color _getTimestampColor(bool isUser, bool isDarkMode) {
    if (isUser) {
      return Colors.purple.shade600;
    } else {
      return isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
    }
  }
}

