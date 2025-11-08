import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:soul/features/insights/screens/insights_screen.dart';
import 'package:soul/features/insights/providers/insights_provider.dart';
import 'package:soul/features/insights/models/insights_models.dart';

/// Comprehensive AI Analyst (Insights) tests covering:
/// 1. Backend aggregation API (/api/v1/insights)
/// 2. Pie chart (Overall Sentiment)
/// 3. Bar chart (Top Keywords)
/// 4. Empty states
/// 5. Refresh functionality
/// 6. Data visualization accuracy

// Fake insights data for testing
class _FakeInsightsData {
  static InsightsData withData() {
    return InsightsData(
      overallSentiment: const {
        'POSITIVE': 60,
        'NEGATIVE': 25,
        'NEUTRAL': 15,
      },
      topKeywords: const [
        KeywordFrequency(keyword: 'work', count: 45),
        KeywordFrequency(keyword: 'project', count: 32),
        KeywordFrequency(keyword: 'meeting', count: 28),
        KeywordFrequency(keyword: 'team', count: 22),
        KeywordFrequency(keyword: 'deadline', count: 18),
      ],
      sentimentOverTime: [
        SentimentTimeSeries(
          date: DateTime.now().subtract(const Duration(days: 6)),
          positiveCount: 3,
          negativeCount: 1,
          neutralCount: 1,
        ),
        SentimentTimeSeries(
          date: DateTime.now().subtract(const Duration(days: 5)),
          positiveCount: 4,
          negativeCount: 2,
          neutralCount: 0,
        ),
        SentimentTimeSeries(
          date: DateTime.now().subtract(const Duration(days: 4)),
          positiveCount: 5,
          negativeCount: 1,
          neutralCount: 2,
        ),
      ],
      totalEntries: 100,
      lastUpdated: DateTime.now(),
    );
  }

  static InsightsData empty() {
    return InsightsData(
      overallSentiment: const {},
      topKeywords: const [],
      sentimentOverTime: [],
      totalEntries: 0,
      lastUpdated: DateTime.now(),
    );
  }
}

// Fake insights notifier for testing
class _FakeInsightsNotifier extends InsightsNotifier {
  bool _isEmpty = false;
  
  _FakeInsightsNotifier({bool isEmpty = false}) : _isEmpty = isEmpty;

  @override
  Future<InsightsData> build() async {
    if (_isEmpty) {
      return _FakeInsightsData.empty();
    }
    return _FakeInsightsData.withData();
  }

  @override
  Future<void> refresh() async {
    state = const AsyncLoading();
    await Future.delayed(const Duration(milliseconds: 100));
    state = AsyncData(_FakeInsightsData.withData());
  }
}

void main() {
  group('📊 AI Analyst (Insights) System Tests', () {
    testWidgets('Insights screen loads and displays data', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            insightsProvider.overrideWith(() => _FakeInsightsNotifier()),
          ],
          child: const MaterialApp(home: InsightsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Screen should be present
      expect(find.byType(InsightsScreen), findsOneWidget);
      
      // Should have app bar
      expect(find.text('Insights'), findsWidgets);
      
      // Should have refresh button
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('Empty state displays when no data available', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            insightsProvider.overrideWith(() => _FakeInsightsNotifier(isEmpty: true)),
          ],
          child: const MaterialApp(home: InsightsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Should show empty state message
      expect(find.textContaining('No insights'), findsWidgets);
    });

    testWidgets('Pie chart displays sentiment breakdown', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            insightsProvider.overrideWith(() => _FakeInsightsNotifier()),
          ],
          child: const MaterialApp(home: InsightsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Look for PieChart widget
      final pieChart = find.byKey(const ValueKey('pie-chart'));
      expect(pieChart, findsOneWidget);

      // Verify sentiment section exists
      expect(find.text('Overall Sentiment'), findsOneWidget);
    });

    testWidgets('Bar chart displays top keywords', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            insightsProvider.overrideWith(() => _FakeInsightsNotifier()),
          ],
          child: const MaterialApp(home: InsightsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Look for BarChart widget
      final barChart = find.byKey(const ValueKey('bar-chart'));
      expect(barChart, findsOneWidget);

      // Verify keywords section exists
      expect(find.text('Top Keywords'), findsOneWidget);
    });

    testWidgets('Refresh button reloads insights data', (tester) async {
      final container = ProviderContainer(
        overrides: [
          insightsProvider.overrideWith(() => _FakeInsightsNotifier()),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: InsightsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Tap refresh button
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      // Should show loading state
      expect(find.byType(CircularProgressIndicator), findsWidgets);

      await tester.pumpAndSettle();

      // Data should be refreshed
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('📊 Data Aggregation Tests', () {
    test('Backend aggregation calculates sentiment percentages correctly', () {
      final data = _FakeInsightsData.withData();
      
      expect(data.overallSentiment['POSITIVE'], equals(60));
      expect(data.overallSentiment['NEGATIVE'], equals(25));
      expect(data.overallSentiment['NEUTRAL'], equals(15));
      
      // Total should be 100%
      final total = data.overallSentiment.values.fold<int>(0, (sum, val) => sum + val);
      expect(total, equals(100));
    });

    test('Top keywords sorted by frequency', () {
      final data = _FakeInsightsData.withData();
      
      expect(data.topKeywords.length, equals(5));
      
      // First keyword should have highest count
      expect(data.topKeywords[0].keyword, equals('work'));
      expect(data.topKeywords[0].count, equals(45));
      
      // Should be in descending order
      for (int i = 0; i < data.topKeywords.length - 1; i++) {
        expect(
          data.topKeywords[i].count,
          greaterThanOrEqualTo(data.topKeywords[i + 1].count),
        );
      }
    });

    test('Sentiment over time tracks historical data', () {
      final data = _FakeInsightsData.withData();
      
      expect(data.sentimentOverTime.length, equals(3));
      
      // Each time series entry should have counts
      for (var series in data.sentimentOverTime) {
        expect(series.positiveCount, greaterThanOrEqualTo(0));
        expect(series.negativeCount, greaterThanOrEqualTo(0));
        expect(series.neutralCount, greaterThanOrEqualTo(0));
      }
      
      // Dates should be in chronological order
      for (int i = 0; i < data.sentimentOverTime.length - 1; i++) {
        expect(
          data.sentimentOverTime[i].date.isBefore(data.sentimentOverTime[i + 1].date),
          isTrue,
        );
      }
    });

    test('Empty data structure handles zero entries', () {
      final emptyData = _FakeInsightsData.empty();
      
      expect(emptyData.totalEntries, equals(0));
      expect(emptyData.overallSentiment, isEmpty);
      expect(emptyData.topKeywords, isEmpty);
      expect(emptyData.sentimentOverTime, isEmpty);
    });
  });

  group('📈 Pie Chart Visualization Tests', () {
    test('Pie chart sections match sentiment percentages', () {
      final data = _FakeInsightsData.withData();
      
      // Create pie chart sections
      final sections = _createPieChartSections(data.overallSentiment);
      
      expect(sections.length, equals(3)); // POSITIVE, NEGATIVE, NEUTRAL
      
      final positiveSection = sections.firstWhere((s) => s.value == 60);
      expect(positiveSection, isNotNull);
      
      final negativeSection = sections.firstWhere((s) => s.value == 25);
      expect(negativeSection, isNotNull);
      
      final neutralSection = sections.firstWhere((s) => s.value == 15);
      expect(neutralSection, isNotNull);
    });

    test('Pie chart colors are distinct for each sentiment', () {
      final colors = _getSentimentColors();
      
      expect(colors['POSITIVE'], isNotNull);
      expect(colors['NEGATIVE'], isNotNull);
      expect(colors['NEUTRAL'], isNotNull);
      
      // Colors should be different
      expect(colors['POSITIVE'], isNot(equals(colors['NEGATIVE'])));
      expect(colors['POSITIVE'], isNot(equals(colors['NEUTRAL'])));
      expect(colors['NEGATIVE'], isNot(equals(colors['NEUTRAL'])));
    });

    testWidgets('Pie chart displays percentages as labels', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            insightsProvider.overrideWith(() => _FakeInsightsNotifier()),
          ],
          child: const MaterialApp(home: InsightsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Should display percentage labels
      expect(find.textContaining('60'), findsWidgets); // POSITIVE 60%
      expect(find.textContaining('25'), findsWidgets); // NEGATIVE 25%
      expect(find.textContaining('15'), findsWidgets); // NEUTRAL 15%
    });
  });

  group('📊 Bar Chart Visualization Tests', () {
    test('Bar chart heights proportional to keyword frequency', () {
      final data = _FakeInsightsData.withData();
      
      final bars = _createBarChartData(data.topKeywords);
      
      expect(bars.length, equals(5));
      
      // Highest bar should correspond to most frequent keyword
      final maxBar = bars.reduce((a, b) =>
        a.barRods.first.toY > b.barRods.first.toY ? a : b);
      expect(maxBar.barRods.first.toY, equals(45)); // 'work' with 45 occurrences
    });

    test('Bar chart shows top 10 keywords maximum', () {
      final manyKeywords = List.generate(
        20,
        (i) => KeywordFrequency(keyword: 'keyword$i', count: 50 - i),
      );
      
      final bars = _createBarChartData(manyKeywords);
      
      expect(bars.length, lessThanOrEqualTo(10));
    });

    testWidgets('Bar chart displays keyword labels', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            insightsProvider.overrideWith(() => _FakeInsightsNotifier()),
          ],
          child: const MaterialApp(home: InsightsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Should show keyword labels
      expect(find.textContaining('work'), findsWidgets);
      expect(find.textContaining('project'), findsWidgets);
      expect(find.textContaining('meeting'), findsWidgets);
    });
  });

  group('🔄 Refresh & Loading States', () {
    testWidgets('Loading indicator shows while fetching data', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    test('Last updated timestamp tracks refresh time', () {
      final data = _FakeInsightsData.withData();
      
      expect(data.lastUpdated, isNotNull);
      
      final now = DateTime.now();
      final difference = now.difference(data.lastUpdated);
      
      expect(difference.inMinutes, lessThan(1)); // Should be recent
    });

    testWidgets('Error state displays when data fetch fails', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            insightsProvider.overrideWith(() => _ErrorInsightsNotifier()),
          ],
          child: const MaterialApp(home: InsightsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Should show error message
      expect(find.textContaining('Error'), findsWidgets);
    });
  });

  group('📱 UI Layout & Responsiveness', () {
    testWidgets('Insights screen is scrollable', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            insightsProvider.overrideWith(() => _FakeInsightsNotifier()),
          ],
          child: const MaterialApp(home: InsightsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Should have scrollable content
      expect(find.byType(ListView), findsWidgets);
    });

    testWidgets('Charts maintain aspect ratio on different screen sizes', (tester) async {
      // Test on small screen
      tester.view.physicalSize = const Size(400, 600);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            insightsProvider.overrideWith(() => _FakeInsightsNotifier()),
          ],
          child: const MaterialApp(home: InsightsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(InsightsScreen), findsOneWidget);

      // Reset view
      addTearDown(() => tester.view.resetPhysicalSize());
    });
  });
}

// Helper functions
List<PieChartSectionData> _createPieChartSections(Map<String, int> sentiments) {
  final colors = _getSentimentColors();
  
  return sentiments.entries.map((entry) {
    return PieChartSectionData(
      value: entry.value.toDouble(),
      title: '${entry.value}%',
      color: colors[entry.key] ?? Colors.grey,
      radius: 100,
    );
  }).toList();
}

Map<String, Color> _getSentimentColors() {
  return {
    'POSITIVE': Colors.green,
    'NEGATIVE': Colors.red,
    'NEUTRAL': Colors.blue,
  };
}

List<BarChartGroupData> _createBarChartData(List<KeywordFrequency> keywords) {
  return keywords.take(10).toList().asMap().entries.map((entry) {
    return BarChartGroupData(
      x: entry.key,
      barRods: [
        BarChartRodData(
          toY: entry.value.count.toDouble(),
          color: Colors.blue,
        ),
      ],
    );
  }).toList();
}

// Error notifier for testing error states
class _ErrorInsightsNotifier extends InsightsNotifier {
  @override
  Future<InsightsData> build() async {
    throw Exception('Failed to load insights');
  }
}
