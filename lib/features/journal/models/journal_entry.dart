class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.body,
    required this.createdAt,
    this.title,
  });

  final String id;
  final String? title;
  final String body;
  final DateTime createdAt;
}
