import 'package:flutter/material.dart';
import '../models/app_models.dart';

class EnhancedQuoteCard extends StatelessWidget {
  final Quote quote;

  const EnhancedQuoteCard({
    required this.quote,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8B4F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '-${quote.author}-',
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.open_in_full, size: 18),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            quote.text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
