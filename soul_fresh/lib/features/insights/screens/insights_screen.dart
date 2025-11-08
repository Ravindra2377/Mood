import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/insights_data.dart';
import '../providers/insights_provider.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen>
    with AutomaticKeepAliveClientMixin {
  static const _sentimentScore = <String, double>{
    'VERY_POSITIVE': 2,
    'POSITIVE': 1.5,
    'NEUTRAL': 1,
    'MIXED': 1,
    'NEGATIVE': 0.5,
    'VERY_NEGATIVE': 0,
  };

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final asyncInsights = ref.watch(insightsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Insights'),
        actions: [
          IconButton(
            tooltip: 'Refresh insights',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(insightsProvider),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: asyncInsights.when(
          loading: () => const Center(
            key: ValueKey('insights-loading'),
            child: CircularProgressIndicator(),
          ),
          error: (error, _) => _ErrorState(
            message: 'Unable to load insights. ${error.toString()}',
          ),
          data: (insights) => _InsightsBody(
            theme: theme,
            insights: insights,
            scoreLookup: _sentimentScore,
          ),
        ),
      ),
    );
  }
}

class _InsightsBody extends StatelessWidget {
  const _InsightsBody({
    required this.theme,
    required this.insights,
    required this.scoreLookup,
  });

  final ThemeData theme;
  final InsightsData insights;
  final Map<String, double> scoreLookup;

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;

    return ListView(
      key: const ValueKey('insights-data'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      children: [
        _SectionCard(
          title: 'Overall Sentiment',
          description: 'Distribution of your journal moods.',
      child: insights.overallSentiment.isEmpty
        ? const KeyedSubtree(
          key: ValueKey('overall-empty'),
          child: _EmptyState(message: 'No sentiment data yet.'),
        )
              : SizedBox(
                  height: 240,
                  child: PieChart(
                    key: const ValueKey('pie-chart'),
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 48,
                      sections: _buildPieChartSections(
                        insights.overallSentiment,
                        theme.textTheme,
                      ),
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 24),
        _SectionCard(
          title: 'Top Keywords',
          description: 'Words you mention most in your reflections.',
      child: insights.topKeywords.isEmpty
        ? const KeyedSubtree(
          key: ValueKey('keywords-empty'),
          child: _EmptyState(message: 'Keywords will appear as you write.'),
        )
              : SizedBox(
                  height: 260,
                  child: BarChart(
                    key: const ValueKey('bar-chart'),
                    BarChartData(
                      barGroups: _buildBarChartGroups(
                        insights.topKeywords,
                        colorScheme.primary,
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(),
                        rightTitles: const AxisTitles(),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: _keywordInterval(insights.topKeywords),
                            getTitlesWidget: (value, meta) => Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(
                                value.toInt().toString(),
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 38,
                            getTitlesWidget: (value, meta) => _getBottomTitles(
                              value,
                              meta,
                              insights.topKeywords,
                              theme.textTheme,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 24),
        _SectionCard(
          title: 'Sentiment Trend',
          description: 'How your reflections felt over the last month.',
          child: insights.sentimentOverTime.isEmpty
              ? const KeyedSubtree(
                  key: ValueKey('trend-empty'),
                  child: _EmptyState(
                    message: 'Once you log entries, we will chart the trend.',
                  ),
                )
              : SizedBox(
                  height: 260,
                  child: LineChart(
                    key: const ValueKey('line-chart'),
                    _buildSentimentTrend(
                      insights.sentimentOverTime,
                      colorScheme,
                      scoreLookup,
                      theme.textTheme,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    Map<String, int> sentimentData,
    TextTheme textTheme,
  ) {
    final total = sentimentData.values.fold<int>(0, (sum, value) => sum + value);
    if (total == 0) {
      return [
        PieChartSectionData(
          color: Colors.grey[300],
          value: 1,
          title: 'No Data',
          radius: 80,
          titleStyle: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
      ];
    }

    final entries = sentimentData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return entries.map((entry) {
      final proportion = entry.value / total;
      final percent = (proportion * 100).round();
      return PieChartSectionData(
        color: _getColorForSentiment(entry.key),
        value: entry.value.toDouble(),
        title: '$percent%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
        ),
      );
    }).toList();
  }

  static double _keywordInterval(List<KeywordData> keywords) {
    final maxCount = keywords.fold<int>(0, (maxValue, item) => max(maxValue, item.count));
    if (maxCount <= 5) {
      return 1;
    }
    return (maxCount / 4).ceilToDouble();
  }

  List<BarChartGroupData> _buildBarChartGroups(
    List<KeywordData> keywords,
    Color barColor,
  ) {
    return keywords.asMap().entries.map((entry) {
      final index = entry.key;
      final keyword = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: keyword.count.toDouble(),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            color: barColor,
            width: 16,
          ),
        ],
      );
    }).toList();
  }

  Widget _getBottomTitles(
    double value,
    TitleMeta meta,
    List<KeywordData> keywordData,
    TextTheme textTheme,
  ) {
    final index = value.toInt();
    if (index < 0 || index >= keywordData.length) {
      return const SizedBox.shrink();
    }

    final keyword = keywordData[index].keyword;
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(
        keyword,
        style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 10),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  LineChartData _buildSentimentTrend(
    List<SentimentTimeData> points,
    ColorScheme colors,
    Map<String, double> scoreLookup,
    TextTheme textTheme,
  ) {
    final sorted = List<SentimentTimeData>.from(points)
      ..sort((a, b) => a.date.compareTo(b.date));

    final formatter = DateFormat('MM/dd');
    final spots = <FlSpot>[];
    final labels = <int, String>{};

    for (var i = 0; i < sorted.length; i++) {
      final point = sorted[i];
      final parsedDate = DateTime.tryParse(point.date);
      final label = parsedDate != null ? formatter.format(parsedDate) : point.date;
      labels[i] = label;

      final sentimentKey = point.sentiment.toUpperCase();
      final y = scoreLookup[sentimentKey] ?? 1;
      spots.add(FlSpot(i.toDouble(), y));
    }

    return LineChartData(
      minY: 0,
      maxY: 2,
      gridData: FlGridData(
        drawVerticalLine: false,
        horizontalInterval: 0.5,
        getDrawingHorizontalLine: (value) => FlLine(
          color: colors.outlineVariant,
          strokeWidth: 0.5,
        ),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(),
        rightTitles: const AxisTitles(),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 44,
            interval: 0.5,
            getTitlesWidget: (value, meta) {
              final label = _sentimentLabel(value, textTheme);
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(label, style: textTheme.bodySmall),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: max(1, spots.length ~/ 5).toDouble(),
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              final label = labels[index];
              if (label == null) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(label, style: textTheme.bodySmall),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          isCurved: true,
          color: colors.primary,
          barWidth: 3,
          spots: spots,
          isStrokeCapRound: true,
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                colors.primary.withOpacity(0.2),
                colors.primary.withOpacity(0.05),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  static String _sentimentLabel(double value, TextTheme textTheme) {
    if (value >= 1.75) return 'Very Positive';
    if (value >= 1.25) return 'Positive';
    if (value >= 0.75) return 'Neutral';
    if (value >= 0.25) return 'Negative';
    return 'Very Negative';
  }

}

Color _getColorForSentiment(String sentiment) {
  switch (sentiment.toUpperCase()) {
    case 'POSITIVE':
    case 'VERY_POSITIVE':
      return Colors.green[400] ?? Colors.green;
    case 'NEGATIVE':
    case 'VERY_NEGATIVE':
      return Colors.red[400] ?? Colors.red;
    case 'NEUTRAL':
    case 'MIXED':
      return Colors.grey[600] ?? Colors.grey;
    default:
      return Colors.blue[400] ?? Colors.blue;
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            child,
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
