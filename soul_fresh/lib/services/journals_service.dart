import 'package:hive/hive.dart';

import '../models/journal_entry.dart';
import 'api_client.dart' as api_client;

/// Abstraction for journal persistence used by UI widgets so tests can
/// inject an in-memory implementation without Hive.
abstract class JournalStore {
  List<JournalEntry> list();
  Future<void> save(JournalEntry entry);
  Future<void> delete(String id);
}

class JournalsService implements JournalStore {
  static const boxName = 'journals';

  final Box<JournalEntry> box;
  final api_client.ApiClient? apiClient;

  JournalsService._(this.box, {this.apiClient});

  /// Open the local box. Optionally provide an [ApiClient] for immediate sync.
  static Future<JournalsService> create(
      {api_client.ApiClient? apiClient,}) async {
    final box = await Hive.openBox<JournalEntry>(boxName);
    return JournalsService._(box, apiClient: apiClient);
  }

  @override
  List<JournalEntry> list() {
    return box.values.toList();
  }

  /// Save locally and attempt to sync to backend when [apiClient] is present.
  ///
  /// On success the entry will be marked `synced = true` and updated with any
  /// server-provided fields. On failure it remains unsynced for retry.
  @override
  Future<void> save(JournalEntry entry) async {
    entry.updatedAt = DateTime.now();

    // Ensure the entry has a local id if missing.
    if (entry.id.isEmpty) {
      entry.id = DateTime.now().microsecondsSinceEpoch.toString();
    }

    // Persist locally first for instant UX.
    await box.put(entry.id, entry);

    // If there's no ApiClient, leave unsynced for later.
    if (apiClient == null) {
      entry.synced = false;
      await box.put(entry.id, entry);
      return;
    }

    try {
      // If already synced with server, perform an update to avoid duplicates.
      if (entry.synced && entry.id.isNotEmpty) {
        final upd = api_client.UpdateJournalRequest(
          title: entry.title,
          content: entry.content,
        );
        final server = await apiClient!.updateJournal(entry.id, upd);
        entry.id = server.id;
        entry.createdAt = server.createdAt;
        entry.updatedAt = server.updatedAt ?? DateTime.now();
        entry.synced = true;
      } else {
        // First-time sync: create on server
        final req = api_client.CreateJournalRequest(
          title: entry.title,
          content: entry.content,
        );
        final server = await apiClient!.createJournal(req);
        entry.id = server.id;
        entry.createdAt = server.createdAt;
        entry.updatedAt = server.updatedAt ?? entry.updatedAt;
        entry.synced = true;
      }

      await box.put(entry.id, entry);
    } catch (e) {
      // Keep entry unsynced; caller can retry later.
      entry.synced = false;
      await box.put(entry.id, entry);
    }
  }

  @override
  Future<void> delete(String id) async {
    // Attempt server delete if we have a client, but do not fail local delete on network error.
    if (apiClient != null) {
      try {
        await apiClient!.deleteJournal(id);
      } catch (_) {
        // ignore
      }
    }
    await box.delete(id);
  }
}

/// Simple in-memory store for tests (no Hive / IO).
class InMemoryJournalStore implements JournalStore {
  final Map<String, JournalEntry> _entries = {};

  @override
  List<JournalEntry> list() => _entries.values.toList();

  @override
  Future<void> save(JournalEntry entry) async {
    if (entry.id.isEmpty) {
      entry.id = DateTime.now().microsecondsSinceEpoch.toString();
    }
    entry.updatedAt = DateTime.now();
    _entries[entry.id] = entry;
  }

  @override
  Future<void> delete(String id) async {
    _entries.remove(id);
  }
}
