import 'package:flutter/foundation.dart';

@immutable
class KeywordFrequency {
  final String keyword;
  final int count;
  const KeywordFrequency({required this.keyword, required this.count});
}

@immutable
class SentimentTimeSeries {
  final DateTime date;
  final int positiveCount;
  final int negativeCount;
  final int neutralCount;
  const SentimentTimeSeries({
    required this.date,
    required this.positiveCount,
    required this.negativeCount,
    required this.neutralCount,
  });
}

@immutable
class InsightsData {
  final Map<String, int> overallSentiment;
  final List<KeywordFrequency> topKeywords;
  final List<SentimentTimeSeries> sentimentOverTime;
  final int totalEntries;
  final DateTime lastUpdated;

  const InsightsData({
    required this.overallSentiment,
    required this.topKeywords,
    required this.sentimentOverTime,
    required this.totalEntries,
    required this.lastUpdated,
  });
}