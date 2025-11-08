/// Data models used by insights feature tests.
/// Lightweight immutable classes with simple factory helpers.

class KeywordFrequency {
  final String keyword;
  final int count;
  const KeywordFrequency({required this.keyword, required this.count});
}

class SentimentTimeSeries {
  final DateTime date;
  final double positive;
  final double neutral;
  final double negative;
  const SentimentTimeSeries({
    required this.date,
    required this.positive,
    required this.neutral,
    required this.negative,
  });
}

class InsightsData {
  final List<KeywordFrequency> topKeywords;
  final List<SentimentTimeSeries> sentimentSeries;
  final int totalEntries;
  const InsightsData({
    required this.topKeywords,
    required this.sentimentSeries,
    required this.totalEntries,
  });

  bool get hasData => topKeywords.isNotEmpty || sentimentSeries.isNotEmpty;
}
