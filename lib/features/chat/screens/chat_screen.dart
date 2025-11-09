import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mood_app/features/chat/models/chat_message.dart';
import 'package:mood_app/features/chat/providers/chat_conversation_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final messages = ref.watch(chatConversationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Companion'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[messages.length - 1 - index];
                return _ChatBubble(message: message);
              },
            ),
          ),
          const _MessageComposer(),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUserMessage = message.sender == ChatSender.user;

    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Card(
        color: isUserMessage
            ? theme.colorScheme.primary
            : theme.colorScheme.surfaceVariant,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: message.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  message.text,
                  style: TextStyle(
                    color: isUserMessage
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                    fontStyle:
                        message.isError ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
        ),
      ),
    );
  }
}

class _MessageComposer extends ConsumerStatefulWidget {
  const _MessageComposer();

  @override
  ConsumerState<_MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends ConsumerState<_MessageComposer> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text;
    if (text.trim().isEmpty || _isSending) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    _controller.clear();

    try {
      await ref.read(chatConversationProvider.notifier).sendMessage(text);
    } finally {
      setState(() {
        _isSending = false;
      });
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Theme.of(context).cardColor,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                textCapitalization: TextCapitalization.sentences,
                autocorrect: true,
                decoration: const InputDecoration(
                  hintText: 'Talk about your day...',
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            IconButton(
              icon: _isSending
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      Icons.send,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              onPressed: _isSending ? null : _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
