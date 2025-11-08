import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:soul/features/insights/screens/insights_screen.dart';
import 'package:soul/features/insights/models/insights_data.dart';
import 'package:soul/features/insights/providers/insights_provider.dart';

class _TestInsightsNotifier extends InsightsNotifier {
  _TestInsightsNotifier(this._data);
  final InsightsData _data;
  @override
  Future<InsightsData> build() async => _data;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('InsightsScreen', () {
    testWidgets('renders charts with data', (tester) async {
      final data = InsightsData(
        overallSentiment: const {
          'POSITIVE': 3,
          'NEUTRAL': 2,
          'NEGATIVE': 1,
        },
        sentimentOverTime: const [
          SentimentTimeData(date: '2025-10-30', sentiment: 'NEUTRAL'),
          SentimentTimeData(date: '2025-11-01', sentiment: 'POSITIVE'),
          SentimentTimeData(date: '2025-11-02', sentiment: 'NEGATIVE'),
        ],
        topKeywords: const [
          KeywordData(keyword: 'sleep', count: 5),
          KeywordData(keyword: 'work', count: 3),
          KeywordData(keyword: 'family', count: 2),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            insightsProvider.overrideWith(() => _TestInsightsNotifier(data)),
          ],
          child: const MaterialApp(home: InsightsScreen()),
        ),
      );
  // Initial frame (loading state expected)
  await tester.pump();
  // Allow async provider + AnimatedSwitcher transition (250ms)
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pumpAndSettle();

      // Data container
      expect(find.byKey(const ValueKey('insights-data')), findsOneWidget);
  // Should not show empty-state messages when data is provided
  expect(find.text('No sentiment data yet.'), findsNothing);
      // Section titles
      expect(find.text('Overall Sentiment'), findsOneWidget);
      expect(find.text('Top Keywords'), findsOneWidget);
      // Scroll to ensure the third section is built (ListView is lazily built)
      await tester.scrollUntilVisible(
        find.text('Sentiment Trend'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Sentiment Trend'), findsOneWidget);
      // No empty-state subtrees for any section
      expect(find.byKey(const ValueKey('overall-empty')), findsNothing);
      expect(find.byKey(const ValueKey('keywords-empty')), findsNothing);
      expect(find.byKey(const ValueKey('trend-empty')), findsNothing);
    });

    testWidgets('shows empty states when no data', (tester) async {
      const empty = InsightsData(
        overallSentiment: {},
        sentimentOverTime: [],
        topKeywords: [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            insightsProvider.overrideWith(() => _TestInsightsNotifier(empty)),
          ],
          child: const MaterialApp(home: InsightsScreen()),
        ),
      );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('insights-data')), findsOneWidget);
      expect(find.text('No sentiment data yet.'), findsOneWidget);
      expect(find.text('Keywords will appear as you write.'), findsOneWidget);
      // Scroll to bring the trend section into view before asserting
      await tester.scrollUntilVisible(
        find.text('Once you log entries, we will chart the trend.'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Once you log entries, we will chart the trend.'), findsOneWidget);
    });
  });
}
