import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_input_field.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../models/journal_entry_view_model.dart';
import '../providers/journal_provider.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _entryController = TextEditingController();

  final List<String> _promptIdeas = const [
    'What is one moment from today you want to hold onto?',
    'Name a feeling you experienced today and what sparked it.',
    'What is something your future self would thank you for?',
    'Which boundary or intention would support you tomorrow?',
    'List three gentle things your mind or body needs right now.',
  ];

  int _activePromptIndex = 0;

  @override
  void dispose() {
    _titleController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<JournalEntryViewModel> entries =
        ref.watch(journalViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.whiteBg,
      appBar: AppBar(
        backgroundColor: AppColors.whiteBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.charcoal),
        title: Text(
          'Journal',
          style: AppTypography.h3.copyWith(
            color: AppColors.charcoal,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _cyclePrompt,
            icon: const Icon(Icons.shuffle_rounded),
            tooltip: 'Another prompt',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPromptCard(),
            const SizedBox(height: 24),
            CustomInputField(
              label: 'Entry title (optional)',
              hint: 'e.g. Evening reflections',
              controller: _titleController,
            ),
            const SizedBox(height: 20),
            CustomInputField(
              label: 'Write what is on your mind',
              hint: 'Let your thoughts flow freely... ',
              controller: _entryController,
              maxLines: 6,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Save entry',
                    onPressed: _saveEntry,
                    backgroundColor: AppColors.primaryPastel,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Clear',
                    onPressed: _clearDraft,
                    isOutlined: true,
                    backgroundColor: AppColors.primaryPastel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Recent reflections',
              style: AppTypography.h4.copyWith(
                color: AppColors.charcoal,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: entries.isEmpty
                  ? Align(
                      alignment: Alignment.topCenter,
                      child: CustomCard(
                        backgroundColor: AppColors.lightGrey,
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Nothing written yet',
                              style: AppTypography.body1.copyWith(
                                color: AppColors.charcoal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Use the prompt above or start free-writing to begin your journaling streak.',
                              style: AppTypography.body2.copyWith(
                                color: AppColors.darkGrey,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: entries.length,
                      padding: const EdgeInsets.only(bottom: 12),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        return CustomCard(
                          backgroundColor: AppColors.white,
                          border: Border.all(
                            color: AppColors.mediumGrey.withOpacity(0.6),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          entry.title ?? 'Untitled entry',
                                          style: AppTypography.body1.copyWith(
                                            color: AppColors.charcoal,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          entry.formattedTimestamp,
                                          style: AppTypography.labelSmall.copyWith(
                                            color: AppColors.mediumGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _deleteEntry(entry.id),
                                    icon: const Icon(Icons.delete_outline),
                                    color: AppColors.mediumGrey,
                                    tooltip: 'Remove entry',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                entry.body,
                                style: AppTypography.body2.copyWith(
                                  color: AppColors.darkGrey,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptCard() {
    final prompt = _promptIdeas[_activePromptIndex];

    return CustomCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primaryPastel.withOpacity(0.95),
          AppColors.accentPastel.withOpacity(0.92),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s prompt',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            prompt,
            style: AppTypography.h4.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _promptIdeas.map((idea) {
              final isSelected = idea == prompt;
              return ChoiceChip(
                label: Text(idea),
                selected: isSelected,
                onSelected: (_) => _selectPrompt(idea),
                selectedColor: AppColors.white.withOpacity(0.25),
                backgroundColor: AppColors.white.withOpacity(0.12),
                labelStyle: AppTypography.labelSmall.copyWith(
                  color: AppColors.white,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: AppColors.white.withOpacity(isSelected ? 0.7 : 0.3),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _cyclePrompt() {
    setState(() {
      _activePromptIndex = (_activePromptIndex + 1) % _promptIdeas.length;
      _prefillDraftIfEmpty();
    });
  }

  void _selectPrompt(String idea) {
    final index = _promptIdeas.indexOf(idea);
    if (index < 0) return;
    setState(() {
      _activePromptIndex = index;
      _prefillDraftIfEmpty();
    });
  }

  void _prefillDraftIfEmpty() {
    if (_entryController.text.trim().isNotEmpty) return;
    final prompt = _promptIdeas[_activePromptIndex];
    _entryController.text = '$prompt\n\n';
    _entryController.selection = TextSelection.fromPosition(
      TextPosition(offset: _entryController.text.length),
    );
  }

  void _saveEntry() {
    final body = _entryController.text.trim();
    final title = _titleController.text.trim();

    if (body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Write a few words before saving. You can use the prompt for inspiration.',
            style: AppTypography.body2.copyWith(color: AppColors.white),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    ref
        .read(journalProvider.notifier)
        .addEntry(title: title.isEmpty ? null : title, body: body);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Journal entry saved',
          style: AppTypography.body2.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.success,
      ),
    );

    _clearDraft();
  }

  void _clearDraft() {
    _titleController.clear();
    _entryController.clear();
  }

  void _deleteEntry(String id) {
    ref.read(journalProvider.notifier).deleteEntry(id);
  }
}
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../../core/widgets/custom_input_field.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _entryController = TextEditingController();
  final List<_JournalEntry> _entries = [];

  final List<String> _promptIdeas = const [
    'What is one moment from today you want to hold onto?',
    'Name a feeling you experienced today and what sparked it.',
    'What is something your future self would thank you for?',
    'Which boundary or intention would support you tomorrow?',
    'List three gentle things your mind or body needs right now.',
  ];

  int _activePromptIndex = 0;

  @override
  void dispose() {
    _titleController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteBg,
      appBar: AppBar(
        backgroundColor: AppColors.whiteBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.charcoal),
        title: Text(
          'Journal',
          style: AppTypography.h3.copyWith(
            color: AppColors.charcoal,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _cyclePrompt,
            icon: const Icon(Icons.shuffle_rounded),
            tooltip: 'Another prompt',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPromptCard(),
            const SizedBox(height: 24),
            CustomInputField(
              label: 'Entry title (optional)',
              hint: 'e.g. Evening reflections',
              controller: _titleController,
            ),
            const SizedBox(height: 20),
            CustomInputField(
              label: 'Write what is on your mind',
              hint: 'Let your thoughts flow freely... ',
              controller: _entryController,
              maxLines: 6,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Save entry',
                    onPressed: _saveEntry,
                    backgroundColor: AppColors.primaryPastel,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Clear',
                    onPressed: _clearDraft,
                    isOutlined: true,
                    backgroundColor: AppColors.primaryPastel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Recent reflections',
              style: AppTypography.h4.copyWith(
                color: AppColors.charcoal,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _entries.isEmpty
                  ? Align(
                      alignment: Alignment.topCenter,
                      child: CustomCard(
                        backgroundColor: AppColors.lightGrey,
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Nothing written yet',
                              style: AppTypography.body1.copyWith(
                                color: AppColors.charcoal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Use the prompt above or start free-writing to begin your journaling streak.',
                              style: AppTypography.body2.copyWith(
                                color: AppColors.darkGrey,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _entries.length,
                      padding: const EdgeInsets.only(bottom: 12),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final entry = _entries[index];
                        return CustomCard(
                          backgroundColor: AppColors.white,
                          border: Border.all(
                            color: AppColors.mediumGrey.withOpacity(0.6),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          entry.title ?? 'Untitled entry',
                                          style: AppTypography.body1.copyWith(
                                            color: AppColors.charcoal,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          entry.formattedTimestamp,
                                          style: AppTypography.labelSmall.copyWith(
                                            color: AppColors.mediumGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _deleteEntry(entry),
                                    icon: const Icon(Icons.delete_outline),
                                    color: AppColors.mediumGrey,
                                    tooltip: 'Remove entry',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                entry.body,
                                style: AppTypography.body2.copyWith(
                                  color: AppColors.darkGrey,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptCard() {
    final prompt = _promptIdeas[_activePromptIndex];

    return CustomCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primaryPastel.withOpacity(0.95),
          AppColors.accentPastel.withOpacity(0.92),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s prompt',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            prompt,
            style: AppTypography.h4.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _promptIdeas.map((idea) {
              final isSelected = idea == prompt;
              return ChoiceChip(
                label: Text(idea),
                selected: isSelected,
                onSelected: (_) => _selectPrompt(idea),
                selectedColor: AppColors.white.withOpacity(0.25),
                backgroundColor: AppColors.white.withOpacity(0.12),
                labelStyle: AppTypography.labelSmall.copyWith(
                  color: AppColors.white,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: AppColors.white.withOpacity(isSelected ? 0.7 : 0.3),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _cyclePrompt() {
    setState(() {
      _activePromptIndex = (_activePromptIndex + 1) % _promptIdeas.length;
      _prefillDraftIfEmpty();
    });
  }

  void _selectPrompt(String idea) {
    final index = _promptIdeas.indexOf(idea);
    if (index < 0) return;
    setState(() {
      _activePromptIndex = index;
      _prefillDraftIfEmpty();
    });
  }

  void _prefillDraftIfEmpty() {
    if (_entryController.text.trim().isNotEmpty) return;
    final prompt = _promptIdeas[_activePromptIndex];
    _entryController.text = '$prompt\n\n';
    _entryController.selection = TextSelection.fromPosition(
      TextPosition(offset: _entryController.text.length),
    );
  }

  void _saveEntry() {
    final body = _entryController.text.trim();
    final title = _titleController.text.trim().isEmpty
        ? null
        : _titleController.text.trim();

    if (body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Write a few words before saving. You can use the prompt for inspiration.',
            style: AppTypography.body2.copyWith(color: AppColors.white),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final now = DateTime.now();

    setState(() {
      _entries.insert(
        0,
        _JournalEntry(
          title: title,
          body: body,
          createdAt: now,
          formattedTimestamp: _formatTimestamp(now),
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Journal entry saved',
          style: AppTypography.body2.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.success,
      ),
    );

    _clearDraft();
  }

  void _clearDraft() {
    setState(() {
      _titleController.clear();
      _entryController.clear();
    });
  }

  void _deleteEntry(_JournalEntry entry) {
    setState(() {
      _entries.remove(entry);
    });
  }

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
}

class _JournalEntry {
  _JournalEntry({
    required this.body,
    required this.createdAt,
    required this.formattedTimestamp,
    this.title,
  });

  final String? title;
  final String body;
  final DateTime createdAt;
  final String formattedTimestamp;
}
