import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/journal_entry.dart';
import '../models/journal_entry_view_model.dart';
import '../services/journal_service.dart';

class JournalNotifier extends StateNotifier<AsyncValue<List<JournalEntry>>> {
  JournalNotifier(this._service) : super(const AsyncValue.loading()) {
    _loadEntries();
  }

  final JournalService _service;

  Future<void> _loadEntries() async {
    final previous = state;
    state = const AsyncValue.loading();
    try {
      final entries = await _service.fetchEntries();
      state = AsyncValue.data(entries);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace, previous: previous);
    }
  }

  Future<void> refresh() => _loadEntries();

  Future<void> addEntry({String? title, required String body}) async {
    final previous = state;
    try {
      final created = await _service.createEntry(title: title, body: body);
      final existing = state.asData?.value ?? const <JournalEntry>[];
      state = AsyncValue.data([created, ...existing]);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace, previous: previous);
      rethrow;
    }
  }

  Future<void> deleteEntry(String id) async {
    final previous = state;
    final existing = state.asData?.value;
    if (existing == null) {
      return;
    }

    final optimistic = existing
        .where((entry) => entry.id != id)
        .toList(growable: false);
    state = AsyncValue.data(optimistic);

    try {
      await _service.deleteEntry(id);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace, previous: previous);
      rethrow;
    }
  }
}

final journalProvider =
    StateNotifierProvider<JournalNotifier, AsyncValue<List<JournalEntry>>>(
  (ref) {
    final service = ref.watch(journalServiceProvider);
    return JournalNotifier(service);
  },
);

final journalViewModelProvider =
    Provider<AsyncValue<List<JournalEntryViewModel>>>((ref) {
  final entriesAsync = ref.watch(journalProvider);
  return entriesAsync.whenData((entries) {
    return entries
        .map(
          (entry) => JournalEntryViewModel.fromEntry(
            entry: entry,
            formattedTimestamp: _formatTimestamp(entry.createdAt),
          ),
        )
        .toList(growable: false);
  });
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
