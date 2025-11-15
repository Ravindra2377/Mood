import 'package:flutter/material.dart';
import '../models/app_models.dart';

class ContentCard extends StatelessWidget {
  final ContentItem item;
  final VoidCallback onTap;

  const ContentCard({
    required this.item,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 80,
                height: 80,
                color: _getBackgroundColor(),
                child: item.thumbnail.startsWith('http')
                    ? Image.network(
                        item.thumbnail,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              _getIcon(),
                              size: 32,
                              color: Colors.white,
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Icon(
                          _getIcon(),
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        _getIcon(),
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_getTypeLabel()} • ${item.duration}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (item.type) {
      case ContentType.article:
        return const Color(0xFFB4D4F0);
      case ContentType.video:
        return const Color(0xFFFFE066);
      case ContentType.audio:
        return const Color(0xFFE8B4F0);
    }
  }

  IconData _getIcon() {
    switch (item.type) {
      case ContentType.article:
        return Icons.article;
      case ContentType.video:
        return Icons.play_circle_outline;
      case ContentType.audio:
        return Icons.headphones;
    }
  }

  String _getTypeLabel() {
    switch (item.type) {
      case ContentType.article:
        return 'Article';
      case ContentType.video:
        return 'Video';
      case ContentType.audio:
        return 'Audio';
    }
  }
}
