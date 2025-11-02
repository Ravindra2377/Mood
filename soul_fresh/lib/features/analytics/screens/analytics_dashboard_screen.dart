import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ai/panda_ai.dart';
import '../../../core/ai/panda_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/animated_panda_companion.dart';
import '../widgets/activity_summary_card.dart';
import '../widgets/assessment_history_card.dart';
import '../widgets/exercise_stats_card.dart';
import '../widgets/mood_trend_chart.dart';
import '../widgets/streak_calendar_widget.dart';
import '../widgets/weekly_insights_card.dart';

class AnalyticsDashboardScreen extends ConsumerStatefulWidget {
  const AnalyticsDashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState
    extends ConsumerState<AnalyticsDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedPeriod = 'Week';
  final PandaAI _pandaAI = PandaAI();
  PandaMood _analyticsMood = PandaMood.focus;
  late String _analyticsMessage;
  Timer? _pandaTimer;
  PandaPreferences? _pandaPreferences;
  PandaPersona _persona = PandaPersona.mindfulMentor;
  String _pandaName = 'Mochi';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _analyticsMessage = _pandaAI.personalizedMessage(
      _analyticsMood,
      persona: _persona,
      name: _pandaName,
    );
    _initializePreferences();
    _startPandaRotation();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pandaTimer?.cancel();
    _pandaPreferences?.removeListener(_handlePreferencesChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => _showPeriodSelector(),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'export') {
                _exportData();
              } else if (value == 'share') {
                _shareProgress();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Export Data'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Share Progress'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Activities'),
            Tab(text: 'Insights'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildActivitiesTab(),
          _buildInsightsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        _updateAnalyticsMood(PandaMood.focus);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAnalyticsPandaCard(),
          const SizedBox(height: 16),
          // Period Selector
          _buildPeriodSelector(),
          const SizedBox(height: 16),

          // Wellness Score Card
          const WellnessScoreCard(),
          const SizedBox(height: 16),

          // Streak & Activity Summary
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: '🔥',
                  label: 'Current Streak',
                  value: '7',
                  subtitle: 'days',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: '✅',
                  label: 'Activities',
                  value: '18',
                  subtitle: 'this week',
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Mood Trend Chart
          const MoodTrendChart(),
          const SizedBox(height: 16),

          // Activity Summary
          const ActivitySummaryCard(),
          const SizedBox(height: 16),

          // Streak Calendar
          const StreakCalendarWidget(),
        ],
      ),
    );
  }

  Widget _buildActivitiesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildAnalyticsPandaCard(compact: true),
        const SizedBox(height: 16),
        // Exercise Stats
        const ExerciseStatsCard(),
        const SizedBox(height: 16),

        // Assessment History
        const AssessmentHistoryCard(),
        const SizedBox(height: 16),

        // Self-Help Activities
        _buildSelfHelpActivitiesCard(),
        const SizedBox(height: 16),

        // Meditation Sessions
        _buildMeditationSessionsCard(),
      ],
    );
  }

  Widget _buildInsightsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildAnalyticsPandaCard(compact: true, headline: 'Here are the trends I spotted'),
        const SizedBox(height: 16),
        // Weekly Insights
        const WeeklyInsightsCard(),
        const SizedBox(height: 16),

        // Pattern Detection
        _buildPatternDetectionCard(),
        const SizedBox(height: 16),

        // Recommendations
        _buildRecommendationsCard(),
        const SizedBox(height: 16),

        // Progress Milestones
        _buildMilestonesCard(),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['Week', 'Month', 'Year', 'All'].map((period) {
            final isSelected = selectedPeriod == period;
            return Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    selectedPeriod = period;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    period,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.grey,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String icon,
    required String label,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelfHelpActivitiesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🧰 Self-Help Activities',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '12 total',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildActivityRow('Thought Records', 5, Colors.blue),
            _buildActivityRow('Check-ins', 4, Colors.green),
            _buildActivityRow('Guided Programs', 3, Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildMeditationSessionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🧘 Meditation Sessions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '8 sessions',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSessionStat('Total Time', '120 min', Icons.timer),
            const SizedBox(height: 8),
            _buildSessionStat('Avg Session', '15 min', Icons.trending_up),
            const SizedBox(height: 8),
            _buildSessionStat('Longest Streak', '5 days', Icons.local_fire_department),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            '$count',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionStat(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildPatternDetectionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'Pattern Detection',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPatternItem(
              '📊 Mood Pattern',
              'Your anxiety peaks on Monday mornings',
              'Consider morning meditation on Mondays',
            ),
            const Divider(height: 24),
            _buildPatternItem(
              '⏰ Best Time',
              'Evening exercises show 25% better results',
              'Schedule activities after 6 PM',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternItem(String title, String description, String suggestion) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.lightbulb, size: 16, color: Colors.blue),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.recommend, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'Personalized Recommendations',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRecommendationItem(
              '🎯',
              'Try Box Breathing',
              'Based on your anxiety patterns',
            ),
            _buildRecommendationItem(
              '📚',
              'Continue 7-Day Anxiety Reset',
              'You\'re 43% complete',
            ),
            _buildRecommendationItem(
              '✍️',
              'Log a Thought Record',
              'Haven\'t done one this week',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(String emoji, String title, String reason) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
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
    );
  }

  Widget _buildMilestonesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                'Milestones',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMilestoneItem(
            '🔥',
            '7-Day Streak',
            'Achieved',
            true,
          ),
          _buildMilestoneItem(
            '📊',
            '10 Assessments',
            '7/10',
            false,
          ),
          _buildMilestoneItem(
            '🧘',
            '50 Exercise Sessions',
            '18/50',
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneItem(
      String emoji, String title, String progress, bool isComplete) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isComplete
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
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
                  style: const TextStyle(fontWeight: FontWeight.w600),
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

  void _showPeriodSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Time Period',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...['Week', 'Month', '3 Months', '6 Months', 'Year', 'All Time']
                .map((period) => ListTile(
                      title: Text(period),
                      trailing: selectedPeriod == period
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                      onTap: () {
                        setState(() {
                          selectedPeriod = period;
                        });
                        _updateAnalyticsMood(PandaMood.focus);
                        Navigator.pop(context);
                      },
                    )),
          ],
        ),
      ),
    );
  }

  void _exportData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('Export your progress data as CSV or PDF?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Export as CSV
              _updateAnalyticsMood(PandaMood.focus);
            },
            child: const Text('CSV'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Export as PDF
              _updateAnalyticsMood(PandaMood.focus);
            },
            child: const Text('PDF'),
          ),
        ],
      ),
    );
  }

  void _shareProgress() {
    _updateAnalyticsMood(PandaMood.celebrate);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Progress shared successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildAnalyticsPandaCard({bool compact = false, String? headline}) {
    final title = headline ?? '$_displayName is cheering every insight';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.coolPastel.withOpacity(0.55)),
        boxShadow: [
          BoxShadow(
            color: AppColors.coolPastel.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTypography.h4.copyWith(
              color: AppColors.charcoal,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          AnimatedPandaCompanion(
            mood: _analyticsMood,
            message: _analyticsMessage,
            size: compact ? 130 : 160,
            onTap: _refreshAnalyticsMessage,
            persona: _persona,
            heroTag: 'panda-companion',
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                label: const Text('Celebrate wins'),
                avatar: const Text('🎉'),
                onPressed: () => _updateAnalyticsMood(PandaMood.celebrate),
              ),
              ActionChip(
                label: const Text('Need motivation'),
                avatar: const Text('✨'),
                onPressed: () => _updateAnalyticsMood(PandaMood.focus),
              ),
              ActionChip(
                label: const Text('Feeling stuck'),
                avatar: const Text('🤔'),
                onPressed: () => _updateAnalyticsMood(PandaMood.lonely),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _initializePreferences() async {
    final prefs = await PandaPreferences.instance();
    if (!mounted) return;

    _pandaPreferences?.removeListener(_handlePreferencesChanged);
    _pandaPreferences = prefs;
    prefs.addListener(_handlePreferencesChanged);

    setState(() {
      _persona = prefs.persona;
      _pandaName = prefs.displayName;
      _updateAnalyticsMessage();
    });
  }

  void _handlePreferencesChanged() {
    final prefs = _pandaPreferences;
    if (prefs == null || !mounted) return;
    setState(() {
      _persona = prefs.persona;
      _pandaName = prefs.displayName;
      _updateAnalyticsMessage();
    });
  }

  String get _displayName => _pandaName.isEmpty ? 'Mochi' : _pandaName;

  void _updateAnalyticsMessage([PandaMood? mood]) {
    final targetMood = mood ?? _analyticsMood;
    _analyticsMessage = _pandaAI.personalizedMessage(
      targetMood,
      persona: _persona,
      name: _displayName,
    );
  }

  void _updateAnalyticsMood(PandaMood mood) {
    setState(() {
      _analyticsMood = mood;
      _updateAnalyticsMessage(mood);
    });
  }

  void _refreshAnalyticsMessage() {
    setState(_updateAnalyticsMessage);
  }

  void _startPandaRotation() {
    _pandaTimer?.cancel();
    _pandaTimer = Timer.periodic(const Duration(seconds: 22), (_) {
      if (!mounted) return;
      _refreshAnalyticsMessage();
    });
  }
}