import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../services/journals_service.dart';

class JournalEditScreen extends StatefulWidget {
  final JournalEntry entry;
  final Future<JournalsService> serviceFuture;
  const JournalEditScreen(
      {super.key, required this.entry, required this.serviceFuture,});

  @override
  State<JournalEditScreen> createState() => _JournalEditScreenState();
}

class _JournalEditScreenState extends State<JournalEditScreen> {
  late TextEditingController _titleCtrl;
  late TextEditingController _contentCtrl;
  String _mood = 'neutral';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.entry.title);
    _contentCtrl = TextEditingController(text: widget.entry.content);
    _mood = widget.entry.mood;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final svc = await widget.serviceFuture;
    widget.entry.title = _titleCtrl.text;
    widget.entry.content = _contentCtrl.text;
    widget.entry.mood = _mood;
    if (widget.entry.id.isEmpty) {
      widget.entry.id = DateTime.now().microsecondsSinceEpoch.toString();
    }
    await svc.save(widget.entry);
    setState(() => _saving = false);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(hintText: 'Title'),),
            const SizedBox(height: 8),
            Expanded(
                child: TextField(
                    controller: _contentCtrl,
                    maxLines: null,
                    expands: true,
                    decoration:
                        const InputDecoration(hintText: 'Write something...'),),),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Mood:'),
                const SizedBox(width: 8),
                DropdownButton<String>(
                    value: _mood,
                    items: const [
                      DropdownMenuItem(value: 'happy', child: Text('😊 Happy')),
                      DropdownMenuItem(value: 'sad', child: Text('😢 Sad')),
                      DropdownMenuItem(
                          value: 'anxious', child: Text('😰 Anxious'),),
                      DropdownMenuItem(
                          value: 'neutral', child: Text('😐 Neutral'),),
                    ],
                    onChanged: (v) => setState(() => _mood = v ?? 'neutral'),),
                const Spacer(),
                ElevatedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Attach coming soon')),),
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Attach'),),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
