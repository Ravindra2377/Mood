import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../models/journal_entry_view_model.dart';
import '../utils/journal_sentiment_style.dart';

class JournalDetailScreen extends StatelessWidget {
  const JournalDetailScreen({super.key, required this.viewModel});

  final JournalEntryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final style = journalSentimentStyleFor(viewModel.sentiment);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal entry'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'journal_entry_${viewModel.id}',
              child: Material(
                color: Colors.transparent,
                child: CustomCard(
                  backgroundColor: AppColors.white,
                  border: Border.all(
                    color: AppColors.mediumGrey.withOpacity(0.55),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        viewModel.title?.trim().isEmpty ?? true
                            ? 'Untitled entry'
                            : viewModel.title!,
                        style: AppTypography.h4.copyWith(
                          color: AppColors.charcoal,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        viewModel.formattedTimestamp,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.mediumGrey,
                        ),
                      ),
                      if (viewModel.sentiment != null &&
                          viewModel.sentiment!.trim().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Chip(
                          avatar: Icon(style.icon, color: style.foreground),
                          label: Text(
                            _formatSentimentLabel(viewModel.sentiment),
                            style: AppTypography.labelSmall.copyWith(
                              color: style.foreground,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          backgroundColor: style.background,
                          shape: StadiumBorder(
                            side: BorderSide(
                              color: style.foreground.withOpacity(0.25),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              viewModel.body,
              style: AppTypography.body1.copyWith(
                color: AppColors.darkGrey,
                height: 1.55,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 24),
            if (viewModel.keywords.isNotEmpty) ...[
              Text(
                'Key themes',
                style: AppTypography.body1.copyWith(
                  color: AppColors.charcoal,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: viewModel.keywords
                    .map((keyword) => keyword.trim())
                    .where((keyword) => keyword.isNotEmpty)
                    .map(
                  (keyword) {
                    return Chip(
                      label: Text(
                        '#$keyword',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.charcoal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: AppColors.lightGrey.withOpacity(0.5),
                    );
                  },
                ).toList(),
              ),
              const SizedBox(height: 16),
            ],
            const Divider(height: 32),
            Text(
              'Remember: small reflections compound.',
              style: AppTypography.body2.copyWith(
                color: AppColors.mediumGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatSentimentLabel(String? raw) {
    final value = raw?.trim();
    if (value == null || value.isEmpty) {
      return 'Neutral';
    }
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }
}
