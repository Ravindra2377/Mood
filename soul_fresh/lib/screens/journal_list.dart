import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/journal_entry.dart';
import '../services/journals_service.dart';
import '../state/app_state.dart';
import 'journal_edit.dart';

class JournalListScreen extends ConsumerStatefulWidget {
  static const route = '/journals';
  const JournalListScreen({super.key});

  @override
  ConsumerState<JournalListScreen> createState() => _JournalListScreenState();
}

class _JournalListScreenState extends ConsumerState<JournalListScreen> {
  late Future<JournalsService> _svcFuture;

  @override
  void initState() {
    super.initState();
    // Will initialize the service in didChangeDependencies where `ref` is available.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final api = ref.read(apiClientProvider);
    _svcFuture = JournalsService.create(apiClient: api);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Journals')),
      body: FutureBuilder<JournalsService>(
        future: _svcFuture,
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final svc = snap.data!;
          final items = svc.list();
          return ListView.builder(
            itemCount: items.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('New entry'),
                  onTap: () async {
                    final id = DateTime.now().microsecondsSinceEpoch.toString();
                    final entry = JournalEntry(id: id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => JournalEditScreen(entry: entry, serviceFuture: _svcFuture),
                      ),
                    );
                  },
                );
              }
              final entry = items[index - 1];
              return ListTile(
                title: Text(entry.title.isEmpty
                    ? entry.content.split('\n').firstWhere((_) => true, orElse: () => 'Untitled')
                    : entry.title),
                subtitle: Text(entry.createdAt.toLocal().toString()),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => JournalEditScreen(entry: entry, serviceFuture: _svcFuture)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
