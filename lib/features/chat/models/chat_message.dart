enum ChatSender {
  user,
  ai,
}

class ChatMessage {
  final String text;
  final ChatSender sender;
  final bool isLoading;
  final bool isError;

  const ChatMessage({
    required this.text,
    required this.sender,
    this.isLoading = false,
    this.isError = false,
  });
}
