class JournalEntryViewModel {
  const JournalEntryViewModel({
    required this.id,
    required this.body,
    required this.formattedTimestamp,
    this.title,
  });

  final String id;
  final String? title;
  final String body;
  final String formattedTimestamp;
}
