import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/journal_entry.dart';
import '../models/journal_entry_view_model.dart';

class JournalNotifier extends StateNotifier<List<JournalEntry>> {
  JournalNotifier() : super(const <JournalEntry>[]);

  static const _uuid = Uuid();

  void addEntry({String? title, required String body}) {
    final trimmedBody = body.trim();
    if (trimmedBody.isEmpty) {
      return;
    }

    final trimmedTitle = title?.trim();
    final entry = JournalEntry(
      id: _uuid.v4(),
      title: trimmedTitle?.isEmpty ?? true ? null : trimmedTitle,
      body: trimmedBody,
      createdAt: DateTime.now(),
    );

  state = [entry, ...state];
  }

  void deleteEntry(String id) {
    if (id.isEmpty) {
      return;
    }

    state = state.where((entry) => entry.id != id).toList(growable: false);
  }

  void clearAll() {
    state = const <JournalEntry>[];
  }
}

final journalProvider =
    StateNotifierProvider<JournalNotifier, List<JournalEntry>>((ref) {
  return JournalNotifier();
});

final journalViewModelProvider = Provider<List<JournalEntryViewModel>>((ref) {
  final entries = ref.watch(journalProvider);

  return entries
      .map(
        (entry) => JournalEntryViewModel(
          id: entry.id,
          title: entry.title,
          body: entry.body,
          formattedTimestamp: _formatTimestamp(entry.createdAt),
        ),
      )
      .toList(growable: false);
});

String _formatTimestamp(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inDays >= 1) {
    return '${dateTime.month}/${dateTime.day}/${dateTime.year} • ${_formatTime(dateTime)}';
  }
  if (difference.inHours >= 1) {
    return '${difference.inHours}h ago • ${_formatTime(dateTime)}';
  }
  if (difference.inMinutes >= 1) {
    return '${difference.inMinutes}m ago • ${_formatTime(dateTime)}';
  }
  return 'Just now • ${_formatTime(dateTime)}';
}

String _formatTime(DateTime dateTime) {
  final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final period = dateTime.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $period';
}
