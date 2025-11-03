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
    final AsyncValue<List<JournalEntryViewModel>> entriesAsync =
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
            Text(
              'Capture your thoughts',
              style: AppTypography.h4.copyWith(
                color: AppColors.charcoal,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            CustomInputField(
              label: 'Title',
              hint: 'Give this entry a name (optional)',
              controller: _titleController,
            ),
            const SizedBox(height: 16),
            CustomInputField(
              label: 'What\'s on your mind?',
              hint: 'Write freely or use the prompt for inspiration.',
              controller: _entryController,
              maxLines: 6,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: CustomButton(
                text: 'Save entry',
                onPressed: () async {
                  await _saveEntry();
                },
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Recent reflections',
              style: AppTypography.h5.copyWith(
                color: AppColors.charcoal,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: entriesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, _) => _JournalErrorState(
                  message: error.toString(),
                  onRetry: () => ref.read(journalProvider.notifier).refresh(),
                ),
                data: (entries) {
                  if (entries.isEmpty) {
                    return Align(
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
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () =>
                        ref.read(journalProvider.notifier).refresh(),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          style:
                                              AppTypography.labelSmall.copyWith(
                                            color: AppColors.mediumGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      await _deleteEntry(entry.id);
                                    },
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
    if (_entryController.text.trim().isNotEmpty) {
      return;
    }
    final prompt = _promptIdeas[_activePromptIndex];
    _entryController.text = '$prompt\n\n';
    _entryController.selection = TextSelection.fromPosition(
      TextPosition(offset: _entryController.text.length),
    );
  }

  Future<void> _saveEntry() async {
    final body = _entryController.text.trim();
    final rawTitle = _titleController.text.trim();
    final title = rawTitle.isEmpty ? null : rawTitle;

    if (body.isEmpty) {
      _showSnackBar(
        'Write a few words before saving. You can use the prompt for inspiration.',
        AppColors.error,
      );
      return;
    }

    try {
      await ref.read(journalProvider.notifier).addEntry(
            title: title,
            body: body,
          );

      if (!mounted) {
        return;
      }

      FocusScope.of(context).unfocus();
      _clearDraft();
      _showSnackBar('Journal entry saved', AppColors.success);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showSnackBar(
        'Unable to save entry. Please try again.',
        AppColors.error,
      );
    }
  }

  void _clearDraft() {
    _titleController.clear();
    _entryController.clear();
  }

  Future<void> _deleteEntry(String id) async {
    try {
      await ref.read(journalProvider.notifier).deleteEntry(id);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showSnackBar(
        'Unable to delete entry. Please try again.',
        AppColors.error,
      );
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTypography.body2.copyWith(color: AppColors.white),
        ),
        backgroundColor: backgroundColor,
      ),
    );
  }
}

class _JournalErrorState extends StatelessWidget {
  const _JournalErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off,
            size: 48,
            color: AppColors.mediumGrey,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.body2.copyWith(
                color: AppColors.mediumGrey,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
