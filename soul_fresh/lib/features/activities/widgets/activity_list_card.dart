import 'package:flutter/material.dart';

import '../models/activity_view_model.dart';

class ActivityListCard extends StatelessWidget {
  const ActivityListCard({
    required this.activity,
    required this.onTap,
    super.key,
  });

  final WellnessActivity activity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color accent = activity.categoryColor;
    final bool showProgress = activity.completionPercentage > 0;
    final bool showRating = activity.rating > 0 && activity.ratingCount > 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      activity.iconEmoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          activity.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          activity.shortDescription,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: <Widget>[
                            _buildInfoPill(
                              label: '${activity.durationMinutes} min',
                              color: accent.withOpacity(0.15),
                              textColor: accent,
                            ),
                            _buildInfoPill(
                              label: _difficultyLabel(activity.difficulty),
                              color: Colors.grey.shade100,
                              textColor: Colors.grey.shade700,
                            ),
                            _buildInfoPill(
                              label: activity.category,
                              color: accent.withOpacity(0.08),
                              textColor: accent,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey.shade500),
                ],
              ),
              if (showProgress) ...<Widget>[
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: activity.completionPercentage / 100,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(accent),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${activity.completionPercentage}% tried',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              if (showRating) ...<Widget>[
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '${activity.rating.toStringAsFixed(1)} (${activity.ratingCount})',
                      style: theme.textTheme.bodySmall,
                    ),
                    if (activity.isPopular) ...<Widget>[
                      const SizedBox(width: 12),
                      _buildInfoPill(
                        label: 'Popular',
                        color: Colors.orange.shade100,
                        textColor: Colors.orange.shade700,
                      ),
                    ],
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: activity.tags.take(4).map((String tag) {
                  return Chip(
                    label: Text(tag),
                    backgroundColor: Colors.grey.shade100,
                    labelStyle: theme.textTheme.bodySmall,
                    side: BorderSide.none,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildInfoPill({
    required String label,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  static String _difficultyLabel(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return 'Easy';
      case DifficultyLevel.medium:
        return 'Moderate';
      case DifficultyLevel.hard:
        return 'Advanced';
    }
  }
}

