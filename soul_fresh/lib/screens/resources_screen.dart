import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/appMockData.dart';
import '../widgets/activity_card.dart';
import '../widgets/enhanced_donut_chart.dart';
import '../widgets/enhanced_quote_card.dart';
import '../widgets/content_card.dart';
import '../state/ui_state.dart';

class ResourcesScreen extends ConsumerWidget {
  static const route = '/resources';

  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gradient = Theme.of(context).extension<SoulGradients>()?.pastel ??
        const LinearGradient(colors: [Colors.blue, Colors.teal]);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(AppMockData.userAvatarUrl),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Search',
                            border: InputBorder.none,
                            icon: Icon(Icons.search, size: 20),
                          ),
                          onChanged: (value) {
                            ref.read(searchQueryProvider.notifier).state = value;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Activities section
                const Text(
                  'Activities',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: AppMockData.activities.length,
                    itemBuilder: (context, index) {
                      final activity = AppMockData.activities[index];
                      return ActivityCard(
                        activity: activity,
                        onTap: () {},
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // Physical state section
                const Text(
                  'Physical state',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: EnhancedDonutChart(
                      percentage: AppMockData.physicalState.percentage,
                      segments: const [
                        ChartSegment(value: 0.48, color: Color(0xFFE8B4F0)),
                        ChartSegment(value: 0.38, color: Color(0xFFA8E6CF)),
                        ChartSegment(value: 0.14, color: Color(0xFFFFE066)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Self Help section
                const Text(
                  'Self Help',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                EnhancedQuoteCard(quote: AppMockData.quote),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.menu_book, size: 32),
                            SizedBox(height: 8),
                            Text(
                              'Journal',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.auto_awesome, size: 32),
                            SizedBox(height: 8),
                            Text(
                              'Practices',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Content items
                ...AppMockData.contentItems.map((item) {
                  return ContentCard(
                    item: item,
                    onTap: () {},
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SoulGradients extends ThemeExtension<SoulGradients> {
  final LinearGradient pastel;
  const SoulGradients({required this.pastel});

  @override
  SoulGradients copyWith({LinearGradient? pastel}) =>
      SoulGradients(pastel: pastel ?? this.pastel);

  @override
  ThemeExtension<SoulGradients> lerp(
    covariant ThemeExtension<SoulGradients>? other,
    double t,
  ) {
    if (other is! SoulGradients) return this;
    return t < .5 ? this : other;
  }
}