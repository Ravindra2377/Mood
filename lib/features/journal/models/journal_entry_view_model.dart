import 'journal_entry.dart';

class JournalEntryViewModel {
  const JournalEntryViewModel({
    required this.id,
    required this.body,
    required this.formattedTimestamp,
    this.title,
    this.mood,
  });

  final String id;
  final String? title;
  final String body;
  final String formattedTimestamp;
  final String? mood;

  factory JournalEntryViewModel.fromEntry({
    required JournalEntry entry,
    required String formattedTimestamp,
  }) {
    return JournalEntryViewModel(
      id: entry.id,
      title: entry.title,
      body: entry.body,
      mood: entry.mood,
      formattedTimestamp: formattedTimestamp,
    );
  }
}
