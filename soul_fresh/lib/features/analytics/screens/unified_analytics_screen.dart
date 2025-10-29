import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/analytics_provider.dart';

class UnifiedAnalyticsScreen extends ConsumerStatefulWidget {
  const UnifiedAnalyticsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UnifiedAnalyticsScreen> createState() =>
      _UnifiedAnalyticsScreenState();
}

class _UnifiedAnalyticsScreenState
    extends ConsumerState<UnifiedAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedPeriod = 'Week';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.calendar_month),
            onSelected: (value) {
              setState(() {
                selectedPeriod = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Week', child: Text('This Week')),
              const PopupMenuItem(value: 'Month', child: Text('This Month')),
              const PopupMenuItem(value: '3Months', child: Text('3 Months')),
              const PopupMenuItem(value: 'Year', child: Text('This Year')),
              const PopupMenuItem(value: 'All', child: Text('All Time')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportData(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Mental Health'),
            Tab(text: 'Activities'),
            Tab(text: 'Insights'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildMentalHealthTab(),
          _buildActivitiesTab(),
          _buildInsightsTab(),
        ],
      ),
    );
  }

  // ==========================================
  // OVERVIEW TAB - Unified Dashboard
  // ==========================================
  Widget _buildOverviewTab() {
    final analyticsAsync = ref.watch(analyticsSnapshotProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        ref.invalidate(analyticsSnapshotProvider);
      },
      child: analyticsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (snapshot) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Overall Wellness Score
            _buildOverallWellnessCard(snapshot),
            const SizedBox(height: 16),

            // Quick Stats Grid
            _buildQuickStatsGrid(snapshot),
            const SizedBox(height: 24),

            // Weekly Trend Chart
            _buildWeeklyTrendChart(),
            const SizedBox(height: 24),

            // Category Breakdown
            _buildCategoryBreakdown(),
            const SizedBox(height: 24),

            // Current Streaks
            _buildStreaksCard(snapshot),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallWellnessCard(snapshot) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFF9966),
            const Color(0xFFFF5E62),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9966).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Overall Wellness Score',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedPeriod,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '↑ 12%',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Large circular progress indicator
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: snapshot.wellnessScore / 100,
                  strokeWidth: 14,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                children: [
                  Text(
                    '${snapshot.wellnessScore}',
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const Text(
                    '/100',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          const Text(
            'You\'re doing great! Keep up the good work 🎉',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsGrid(snapshot) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickStatCard(
            icon: '🔥',
            value: '${snapshot.currentStreak}',
            label: 'Day Streak',
            color: Colors.orange,
            trend: '+2',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickStatCard(
            icon: '✅',
            value: '${snapshot.exerciseStats.totalSessions + snapshot.selfHelpStats.totalActivities}',
            label: 'Activities',
            color: Colors.green,
            trend: '+5',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickStatCard(
            icon: '⏱️',
            value: '${snapshot.exerciseStats.totalTimeMinutes + snapshot.selfHelpStats.totalTimeMinutes}',
            label: 'Minutes',
            color: Colors.blue,
            trend: '+120',
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatCard({
    required String icon,
    required String value,
    required String label,
    required Color color,
    required String trend,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(icon, style: const TextStyle(fontSize: 28)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  trend,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyTrendChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '📊 Weekly Trend',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Last 7 Days',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Bar chart
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildChartBar('Mon', 0.7, const Color(0xFF4CAF50)),
                _buildChartBar('Tue', 0.8, const Color(0xFF4CAF50)),
                _buildChartBar('Wed', 0.6, const Color(0xFFFFC107)),
                _buildChartBar('Thu', 0.85, const Color(0xFF4CAF50)),
                _buildChartBar('Fri', 0.75, const Color(0xFF4CAF50)),
                _buildChartBar('Sat', 0.9, const Color(0xFF4CAF50)),
                _buildChartBar('Sun', 0.82, const Color(0xFF4CAF50)),
              ],
            ),
            const SizedBox(height: 20),

            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(const Color(0xFF4CAF50), 'Good Days'),
                const SizedBox(width: 16),
                _buildLegendItem(const Color(0xFFFFC107), 'Okay Days'),
                const SizedBox(width: 16),
                _buildLegendItem(const Color(0xFFF44336), 'Difficult Days'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartBar(String day, double value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 120 * value,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color,
                color.withOpacity(0.6),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📋 Category Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            _buildCategoryItem('😊', 'Mood', 7.3, 0.73, Colors.amber),
            const SizedBox(height: 16),
            _buildCategoryItem('⚡', 'Energy', 7.0, 0.70, Colors.orange),
            const SizedBox(height: 16),
            _buildCategoryItem('😰', 'Stress', 6.2, 0.62, Colors.red),
            const SizedBox(height: 16),
            _buildCategoryItem('😴', 'Sleep', 7.2, 0.72, Colors.purple),
            const SizedBox(height: 16),
            _buildCategoryItem('👥', 'Social', 7.0, 0.70, Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
    String emoji,
    String label,
    double score,
    double progress,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${score.toStringAsFixed(1)}/10',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStreaksCard(snapshot) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.teal.shade400,
              Colors.teal.shade600,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              '🔥 Active Streaks',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStreakItem('🧘', '${snapshot.currentStreak} days', 'Meditation'),
                ),
                Container(
                  width: 1,
                  height: 60,
                  color: Colors.white.withOpacity(0.3),
                ),
                Expanded(
                  child: _buildStreakItem('😊', '${snapshot.currentStreak} days', 'Mood Tracking'),
                ),
                Container(
                  width: 1,
                  height: 60,
                  color: Colors.white.withOpacity(0.3),
                ),
                Expanded(
                  child: _buildStreakItem('😴', '${snapshot.currentStreak} days', 'Sleep Log'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakItem(String emoji, String days, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        Text(
          days,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ==========================================
  // MENTAL HEALTH TAB
  // ==========================================
  Widget _buildMentalHealthTab() {
    final moodStatsAsync = ref.watch(moodStatsProvider);

    return moodStatsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (moodStats) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Anxiety Analytics
          _buildAnxietyAnalyticsCard(),
          const SizedBox(height: 16),

          // Stress Analytics
          _buildStressAnalyticsCard(),
          const SizedBox(height: 16),

          // Mood Analytics
          _buildMoodAnalyticsCard(moodStats),
        ],
      ),
    );
  }

  Widget _buildAnxietyAnalyticsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.psychology, color: Colors.blue),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Anxiety Levels',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Weekly Average: 5.8/10',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.trending_down, color: Colors.green),
              ],
            ),
            const SizedBox(height: 20),

            // Recent anxiety logs
            _buildAnxietyLogItem('Work deadline', '8/10', 'Deep breathing'),
            const Divider(height: 24),
            _buildAnxietyLogItem('Social gathering', '6/10', 'Exercise'),
            const Divider(height: 24),
            _buildAnxietyLogItem('Financial worries', '7/10', 'Meditation'),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('View Full Analytics'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnxietyLogItem(String trigger, String level, String coping) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                trigger,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                coping,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getAnxietyLevelColor(level).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            level,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _getAnxietyLevelColor(level),
            ),
          ),
        ),
      ],
    );
  }

  Color _getAnxietyLevelColor(String level) {
    final score = int.parse(level.split('/')[0]);
    if (score >= 8) return Colors.red;
    if (score >= 6) return Colors.orange;
    return Colors.green;
  }

  Widget _buildStressAnalyticsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.trending_up, color: Colors.red),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stress Triggers',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Top 3 this week',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildTriggerItem('Work', 12, 0.7),
            const SizedBox(height: 12),
            _buildTriggerItem('Family', 8, 0.5),
            const SizedBox(height: 12),
            _buildTriggerItem('Sleep', 5, 0.3),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.psychology, size: 18),
                    label: const Text('Exercises', style: TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.insights, size: 18),
                    label: const Text('Insights', style: TextStyle(fontSize: 13)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTriggerItem(String label, int count, double percentage) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${count}x',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percentage,
                  minHeight: 6,
                  backgroundColor: Colors.grey,
                  valueColor: const AlwaysStoppedAnimation(Colors.red),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMoodAnalyticsCard(moodStats) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.mood, color: Colors.amber),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mood Insights',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Weekly: 7.3 ↑ Improving',
                        style: TextStyle(fontSize: 12, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text(
              'Top Mood Boosters',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildMoodBoosterItem('Exercise', 12, 4),
            const SizedBox(height: 8),
            _buildMoodBoosterItem('Time with Friends', 8, 4),
            const SizedBox(height: 8),
            _buildMoodBoosterItem('Reading', 6, 4),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('View Calendar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodBoosterItem(String activity, int times, int stars) {
    return Row(
      children: [
        Expanded(
          child: Text(activity, style: const TextStyle(fontSize: 14)),
        ),
        Text(
          'Used $times times',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(width: 8),
        ...List.generate(
          5,
          (index) => Icon(
            index < stars ? Icons.star : Icons.star_border,
            size: 16,
            color: Colors.amber,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // ACTIVITIES TAB
  // ==========================================
  Widget _buildActivitiesTab() {
    final exerciseStatsAsync = ref.watch(exerciseStatsProvider);
    final selfHelpStatsAsync = ref.watch(selfHelpStatsProvider);

    return exerciseStatsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (exerciseStats) => selfHelpStatsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (selfHelpStats) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Meditation Stats
            _buildMeditationStatsCard(exerciseStats, selfHelpStats),
            const SizedBox(height: 16),

            // Sleep Stats
            _buildSleepStatsCard(),
            const SizedBox(height: 16),

            // Exercise Stats
            _buildExerciseStatsCard(exerciseStats),
          ],
        ),
      ),
    );
  }

  Widget _buildMeditationStatsCard(exerciseStats, selfHelpStats) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    '🧘 ',
                    style: TextStyle(fontSize: 28),
                  ),
                  const Expanded(
                    child: Text(
                      'Mindfulness & Meditation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: _buildMeditationStat(
                      '🔥',
                      '${exerciseStats.totalSessions}',
                      'Current Streak',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 60,
                    color: Colors.grey,
                  ),
                  Expanded(
                    child: _buildMeditationStat(
                      '⭐',
                      '${exerciseStats.totalSessions}',
                      'Best Streak',
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),

              Row(
                children: [
                  Expanded(
                    child: _buildMeditationStat(
                      '🧘',
                      '${exerciseStats.totalSessions}',
                      'Total Sessions',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 60,
                    color: Colors.grey,
                  ),
                  Expanded(
                    child: _buildMeditationStat(
                      '⏱️',
                      '${exerciseStats.totalTimeMinutes} min',
                      'Total Time',
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),

              Row(
                children: [
                  Expanded(
                    child: _buildMeditationStat(
                      '⭐',
                      '4.2/5',
                      'Avg Focus',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 60,
                    color: Colors.grey,
                  ),
                  Expanded(
                    child: _buildMeditationStat(
                      '📈',
                      '${exerciseStats.totalSessions}',
                      'This Week',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeditationStat(String icon, String value, String label) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSleepStatsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    '😴 ',
                    style: TextStyle(fontSize: 28),
                  ),
                  const Expanded(
                    child: Text(
                      'Sleep Tracking',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'On Track',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sleep quality score
              Center(
                child: Column(
                  children: [
                    const Text(
                      '7.2',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const Text(
                      'Average Sleep Quality',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Icon(
                          index < 4 ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 28,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Factors Affecting Sleep',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildSleepFactorItem('👍 Good Sleep', '85%', Colors.green),
              const SizedBox(height: 8),
              _buildSleepFactorItem('👎 Caffeine Late', '65%', Colors.red),
              const SizedBox(height: 8),
              _buildSleepFactorItem('👎 Screen Time', '45%', Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSleepFactorItem(String label, String percentage, Color color) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 14)),
        ),
        Text(
          percentage,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseStatsCard(exerciseStats) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💪 Coping Exercises',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildExerciseItem('4-7-8 Breathing', exerciseStats.totalSessions, 4),
            const Divider(height: 24),
            _buildExerciseItem('Box Breathing', exerciseStats.totalSessions, 4),
            const Divider(height: 24),
            _buildExerciseItem('Progressive Relaxation', exerciseStats.totalSessions, 4),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('View All Exercises'),
              ),
            ),
          ],
        ),
      ),
    );
  }  Widget _buildExerciseItem(String name, int sessions, int effectiveness) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$sessions sessions',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < effectiveness ? Icons.star : Icons.star_border,
              size: 16,
              color: Colors.amber,
            );
          }),
        ),
      ],
    );
  }

  // ==========================================
  // INSIGHTS TAB
  // ==========================================
  Widget _buildInsightsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildKeyInsightsCard(),
        const SizedBox(height: 16),
        _buildPatternsCard(),
        const SizedBox(height: 16),
        _buildRecommendationsCard(),
        const SizedBox(height: 16),
        _buildMilestonesCard(),
      ],
    );
  }

  Widget _buildKeyInsightsCard() {
    return Card(
      elevation: 2,
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb, color: Colors.blue, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Key Insights',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInsightItem(
              '📈',
              'Improving Trend',
              'Your overall wellness has improved by 12% this week!',
            ),
            const SizedBox(height: 16),
            _buildInsightItem(
              '🌙',
              'Better Sleep',
              'Meditation before bed improved your sleep quality by 23%',
            ),
            const SizedBox(height: 16),
            _buildInsightItem(
              '💪',
              'Effective Strategy',
              'Breathing exercises are your most effective anxiety reliever',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(String emoji, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPatternsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.purple, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Patterns Detected',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildPatternItem(
              '📅 Monday Blues',
              'Your anxiety peaks on Monday mornings',
              'Try morning meditation on Mondays',
            ),
            const Divider(height: 24),
            _buildPatternItem(
              '⏰ Evening Improvement',
              'Evening exercises show 25% better results',
              'Schedule activities after 6 PM',
            ),
            const Divider(height: 24),
            _buildPatternItem(
              '🌙 Sleep Connection',
              '7+ hours of sleep correlates with better mood',
              'Maintain consistent sleep schedule',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternItem(String title, String pattern, String suggestion) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          pattern,
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.lightbulb_outline, size: 16, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  suggestion,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.recommend, color: Colors.amber, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Personalized Recommendations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildRecommendationItem(
              '🫁',
              'Try Box Breathing',
              'Based on your anxiety patterns',
            ),
            const SizedBox(height: 12),
            _buildRecommendationItem(
              '🧘',
              'Evening Meditation',
              'Improves your sleep quality',
            ),
            const SizedBox(height: 12),
            _buildRecommendationItem(
              '📝',
              'Start Journaling',
              'Track your mood boosters',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(String emoji, String title, String reason) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    reason,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestonesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Achievements & Milestones',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildMilestoneItem('🔥', '7-Day Streak', 'Completed', true),
            const SizedBox(height: 12),
            _buildMilestoneItem('🧘', '50 Meditation Sessions', '35/50', false),
            const SizedBox(height: 12),
            _buildMilestoneItem('📊', '30-Day Tracker', '12/30', false),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestoneItem(
    String emoji,
    String title,
    String progress,
    bool isComplete,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isComplete
            ? Colors.green.withOpacity(0.1)
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isComplete ? Colors.green : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isComplete
                  ? Colors.green.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  progress,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Icon(
            isComplete ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isComplete ? Colors.green : Colors.grey,
          ),
        ],
      ),
    );
  }

  void _exportData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Analytics'),
        content: const Text('Export your wellness data as PDF or CSV?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Export as CSV
            },
            child: const Text('CSV'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Export as PDF
            },
            child: const Text('PDF'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}