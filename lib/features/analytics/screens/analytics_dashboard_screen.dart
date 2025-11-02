import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/analytics_provider.dart';
import '../widgets/exercise_analytics_widget.dart';
import '../widgets/self_help_analytics_widget.dart';
import '../widgets/mood_analytics_widget.dart';

class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsSnapshot = ref.watch(analyticsSnapshotProvider);
    final exerciseStats = ref.watch(exerciseStatsProvider);
    final selfHelpStats = ref.watch(selfHelpStatsProvider);
    final moodStats = ref.watch(moodStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(analyticsSnapshotProvider);
          ref.refresh(exerciseStatsProvider);
          ref.refresh(selfHelpStatsProvider);
          ref.refresh(moodStatsProvider);
        },
        child: analyticsSnapshot.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error: $error'),
          ),
          data: (snapshot) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Wellness Score Card
              _buildWellnessCard(context, snapshot),
              const SizedBox(height: 16),

              // Key Metrics
              _buildKeyMetricsCard(context, snapshot),
              const SizedBox(height: 16),

              // Exercise Analytics
              exerciseStats.when(
                data: (stats) => ExerciseAnalyticsWidget(stats: stats),
                loading: () => const SizedBox.shrink(),
                error: (error, stack) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),

              // Self-Help Analytics
              selfHelpStats.when(
                data: (stats) => SelfHelpAnalyticsWidget(stats: stats),
                loading: () => const SizedBox.shrink(),
                error: (error, stack) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),

              // Mood Analytics
              moodStats.when(
                data: (stats) => MoodAnalyticsWidget(stats: stats),
                loading: () => const SizedBox.shrink(),
                error: (error, stack) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWellnessCard(BuildContext context, AnalyticsSnapshot snapshot) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Wellness Score',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: snapshot.wellnessScore / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              Column(
                children: [
                  Text(
                    '${snapshot.wellnessScore}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    '/100',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${snapshot.currentStreak}-day streak! 🔥',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetricsCard(BuildContext context, AnalyticsSnapshot snapshot) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Week Overview',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricItem(
                  '${snapshot.exerciseStats.totalSessions}',
                  'Exercises',
                  '🏃',
                ),
                _buildMetricItem(
                  '${snapshot.selfHelpStats.totalActivities}',
                  'Activities',
                  '✅',
                ),
                _buildMetricItem(
                  '${snapshot.moodStats.entries.length}',
                  'Check-ins',
                  '📊',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String value, String label, String icon) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}