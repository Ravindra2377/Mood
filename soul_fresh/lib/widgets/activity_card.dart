import 'package:flutter/material.dart';
import '../models/app_models.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;
  final VoidCallback onTap;

  const ActivityCard({
    required this.activity,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Use Material + InkWell for proper tap handling and ripple effect
    return Material(
      color: activity.color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 140,
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(16),
          // color moved to Material
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  activity.icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const Spacer(),
              Text(
                activity.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

