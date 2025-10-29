/// Main self-help chat screen with AI companion.
/// Includes message display, input, typing indicator, and crisis detection.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soul/models/chat_models.dart';
import 'package:soul/features/self_help/controllers/chat_controller.dart';
import 'package:soul/features/self_help/widgets/chat_bubble.dart';
import 'package:soul/features/self_help/widgets/typing_indicator.dart';
import 'package:soul/features/self_help/widgets/crisis_dialog.dart';

class SelfHelpChatScreen extends ConsumerStatefulWidget {
  final String? initialSessionId;

  const SelfHelpChatScreen({
    Key? key,
    this.initialSessionId,
  }) : super(key: key);

  @override
  ConsumerState<SelfHelpChatScreen> createState() => _SelfHelpChatScreenState();
}

class _SelfHelpChatScreenState extends ConsumerState<SelfHelpChatScreen> {
  late TextEditingController _messageController;
  late ScrollController _scrollController;
  final FocusNode _focusNode = FocusNode();
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();

    _scrollController.addListener(_handleScroll);

    // Load existing session or create new one
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(chatControllerProvider.notifier);
      if (widget.initialSessionId != null) {
        controller.loadHistory(widget.initialSessionId!);
      } else {
        controller.newSession();
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final shouldShow = _scrollController.offset <
        _scrollController.position.maxScrollExtent - 100;

    if (shouldShow != _showScrollToBottom) {
      setState(() => _showScrollToBottom = shouldShow);
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();
    _focusNode.unfocus();

    ref.read(chatControllerProvider.notifier).sendMessage(message);

    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatControllerProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('SOUL AI Assistant'),
            Text(
              'Active • Available 24/7',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
          ),
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'new',
                child: Text('New Conversation'),
              ),
              const PopupMenuItem<String>(
                value: 'history',
                child: Text('View History'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'clear',
                child: Text('Clear Chat'),
              ),
            ],
            onSelected: _handleMenuAction,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Messages list
              Expanded(
                child: chatState.messages.isEmpty
                    ? _buildWelcomeMessage()
                    : _buildMessagesList(chatState, isDarkMode),
              ),

              // Crisis response dialog
              if (chatState.crisisResponse != null)
                _buildCrisisPanel(chatState.crisisResponse!),

              // Input area
              _buildInputArea(),
            ],
          ),

          // Scroll to bottom button
          if (_showScrollToBottom)
            Positioned(
              bottom: 100,
              right: 16,
              child: FloatingActionButton(
                mini: true,
                onPressed: _scrollToBottom,
                child: const Icon(Icons.arrow_downward),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade400,
                    Colors.teal.shade400,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 50)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to SOUL AI Assistant',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'I\'m here to listen, support, and guide you through mental health challenges. '
              'Feel free to share what\'s on your mind.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildQuickStarters(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStarters() {
    final starters = [
      ('😰', 'I\'m feeling anxious'),
      ('😴', 'I can\'t sleep'),
      ('😞', 'I\'m feeling depressed'),
      ('😤', 'I\'m stressed'),
      ('🤔', 'I need advice'),
      ('💭', 'Just want to talk'),
    ];

    return Column(
      children: [
        Text(
          'Quick starters:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: starters.map((starter) {
            return ActionChip(
              avatar: Text(starter.$1, style: const TextStyle(fontSize: 18)),
              label: Text(starter.$2),
              onPressed: () {
                _messageController.text = starter.$2;
                _focusNode.requestFocus();
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMessagesList(ChatState state, bool isDarkMode) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: state.messages.length + (state.isStreaming ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.messages.length) {
          return const TypingIndicator();
        }

        final message = state.messages[index];
        return ChatBubble(
          message: message,
          isDarkMode: isDarkMode,
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: _focusNode,
              maxLines: null,
              minLines: 1,
              maxLength: 500,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                counterText: '',
              ),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            mini: true,
            onPressed: _sendMessage,
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  Widget _buildCrisisPanel(CrisisResponse crisis) {
    return CrisisDialog(
      crisis: crisis,
      onDismiss: () {
        ref.read(chatControllerProvider.notifier).clearCrisisResponse();
      },
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About SOUL AI'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SOUL AI is your personal mental health companion, '
                'available 24/7 to provide support and guidance.',
              ),
              const SizedBox(height: 16),
              const Text(
                'Important:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '• I am not a licensed therapist\n'
                '• This is not a substitute for professional help\n'
                '• In crisis, please contact emergency services\n'
                '• Your conversations are private and encrypted',
              ),
              const SizedBox(height: 16),
              Text(
                'Version: 1.0.0',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'new':
        ref.read(chatControllerProvider.notifier).newSession();
        _messageController.clear();
        _scrollToBottom();
        break;

      case 'history':
        // TODO: Show session history
        break;

      case 'clear':
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Clear Chat?'),
            content: const Text(
              'Are you sure you want to clear this conversation? '
              'This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(chatControllerProvider.notifier).newSession();
                },
                child: const Text('Clear'),
              ),
            ],
          ),
        );
        break;
    }
  }
}
