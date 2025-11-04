import 'journal_entry.dart';

class JournalEntryViewModel {
  const JournalEntryViewModel({
    required this.id,
    required this.body,
    required this.formattedTimestamp,
    this.title,
    this.mood,
    this.sentiment,
    this.sentimentScore,
    this.keywords = const <String>[],
  });

  final String id;
  final String? title;
  final String body;
  final String formattedTimestamp;
  final String? mood;
  final String? sentiment;
  final double? sentimentScore;
  final List<String> keywords;

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
      sentiment: entry.sentiment,
      sentimentScore: entry.sentimentScore,
      keywords: List<String>.unmodifiable(entry.keywords),
    );
  }
}
