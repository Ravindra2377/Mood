import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul/features/insights/models/insights_data.dart';
import 'package:soul/features/insights/providers/insights_provider.dart';
import 'package:soul/features/insights/screens/insights_screen.dart';

// A test-only data source the notifier will read from
final _testInsightsDataProvider = StateProvider<InsightsData>((ref) {
  return const InsightsData(
    overallSentiment: {},
    sentimentOverTime: [],
    topKeywords: [],
  );
});

class _RefreshableInsights extends InsightsNotifier {
  @override
  Future<InsightsData> build() async {
    // Return whatever the test provider currently holds
    return ref.watch(_testInsightsDataProvider);
  }
}

void main() {
  testWidgets('Insights refresh button reloads with new data', (tester) async {
    // Start with empty data so empty-states are visible
    const empty = InsightsData(
      overallSentiment: {},
      sentimentOverTime: [],
      topKeywords: [],
    );
    const withData = InsightsData(
      overallSentiment: {'POSITIVE': 2, 'NEUTRAL': 1},
      sentimentOverTime: [
        SentimentTimeData(date: '2025-11-08', sentiment: 'POSITIVE'),
      ],
      topKeywords: [KeywordData(keyword: 'calm', count: 3)],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          _testInsightsDataProvider.overrideWith((ref) => empty),
          insightsProvider.overrideWith(_RefreshableInsights.new),
        ],
        child: const MaterialApp(home: InsightsScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Initially shows empty states
    expect(find.byKey(const ValueKey('overall-empty')), findsOneWidget);
    expect(find.byKey(const ValueKey('keywords-empty')), findsOneWidget);
    // Trend may be offscreen; still okay to assert empty key after scroll
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('trend-empty')),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('trend-empty')), findsOneWidget);

    // Now update the underlying data to non-empty
    final container =
        ProviderScope.containerOf(tester.element(find.byType(InsightsScreen)));
    // Update test data provider
    container.read(_testInsightsDataProvider.notifier).state = withData;

    // Tap the AppBar refresh button to invalidate/rebuild
    final refreshButton = find.byTooltip('Refresh insights');
    expect(refreshButton, findsOneWidget);
    await tester.tap(refreshButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // After refresh, empty states disappear
    expect(find.byKey(const ValueKey('overall-empty')), findsNothing);
    expect(find.byKey(const ValueKey('keywords-empty')), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Sentiment Trend'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('trend-empty')), findsNothing);
  });
}
