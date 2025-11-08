import 'package:flutter/material.dart';

import '../models/activity_view_model.dart';

class RecommendedActivityCard extends StatelessWidget {
  const RecommendedActivityCard({
    required this.activity,
    required this.onTap,
    super.key,
  });

  final WellnessActivity activity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color base = activity.categoryColor;

    return Container(
      width: 160,
      margin: const EdgeInsets.only(left: 16, right: 4, bottom: 12, top: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            base.withOpacity(0.85),
            base.withOpacity(0.55),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: base.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Align(
                  alignment: Alignment.topRight,
                  child: _buildBadge(activity),
                ),
                Text(
                  activity.iconEmoji,
                  style: const TextStyle(fontSize: 36),
                ),
                const Spacer(),
                Text(
                  activity.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    const Icon(Icons.timer, color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${activity.durationMinutes} min',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(WellnessActivity activity) {
    if (activity.isRecommended) {
      return const _Badge(
        label: 'Recommended',
        icon: Icons.lightbulb_outline,
      );
    }
    if (activity.isPopular) {
      return const _Badge(
        label: 'Popular',
        icon: Icons.local_fire_department_outlined,
      );
    }
    return const SizedBox.shrink();
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
