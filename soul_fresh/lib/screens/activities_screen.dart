import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/appMockData.dart';
import '../state/ui_state.dart';
import '../widgets/calendar_week_view.dart';
import '../widgets/enhanced_donut_chart.dart';

class ActivitiesScreen extends ConsumerWidget {
  static const route = '/activities';

  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gradient = Theme.of(context).extension<SoulGradients>()?.pastel ??
        const LinearGradient(colors: [Colors.blue, Colors.teal]);
    final selectedDay = ref.watch(selectedCalendarDayProvider);

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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(AppMockData.userAvatarUrl),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Title
                const Text(
                  'Your Activities',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                // Calendar week view
                CalendarWeekView(
                  days: AppMockData.calendarWeek,
                  onDaySelected: (date) {
                    ref.read(selectedCalendarDayProvider.notifier).state = date;
                  },
                ),
                const SizedBox(height: 24),
                // Activity stats cards
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: AppMockData.activityStats.length,
                    itemBuilder: (context, index) {
                      final stat = AppMockData.activityStats[index];
                      return Container(
                        width: 140,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: stat.color,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(stat.icon, size: 24),
                            const Spacer(),
                            Text(
                              stat.title,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              stat.value,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
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
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      // Donut chart
                      EnhancedDonutChart(
                        percentage: AppMockData.physicalState.percentage,
                        segments: const [
                          ChartSegment(value: 0.48, color: Color(0xFFE8B4F0)),
                          ChartSegment(value: 0.38, color: Color(0xFFA8E6CF)),
                          ChartSegment(value: 0.14, color: Color(0xFFFFE066)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Metrics
                      _MetricRow(
                        color: const Color(0xFFE8B4F0),
                        label: 'Sleep Goal',
                        value: AppMockData.physicalState.sleepGoal,
                      ),
                      const SizedBox(height: 12),
                      _MetricRow(
                        color: const Color(0xFFA8E6CF),
                        label: 'Last night',
                        value: AppMockData.physicalState.lastNight,
                      ),
                      const SizedBox(height: 12),
                      _MetricRow(
                        color: const Color(0xFFFFE066),
                        label: 'Deficit',
                        value: AppMockData.physicalState.deficit,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _MetricRow({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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