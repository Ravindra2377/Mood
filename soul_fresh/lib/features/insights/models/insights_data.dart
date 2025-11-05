class SentimentTimeData {
  final String date;
  final String sentiment;

  const SentimentTimeData({
    required this.date,
    required this.sentiment,
  });

  factory SentimentTimeData.fromJson(Map<String, dynamic> json) {
    return SentimentTimeData(
      date: json['date'] as String? ?? '',
      sentiment: json['sentiment'] as String? ?? '',
    );
  }
}

class KeywordData {
  final String keyword;
  final int count;

  const KeywordData({
    required this.keyword,
    required this.count,
  });

  factory KeywordData.fromJson(Map<String, dynamic> json) {
    return KeywordData(
      keyword: json['keyword'] as String? ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}

class InsightsData {
  final Map<String, int> overallSentiment;
  final List<SentimentTimeData> sentimentOverTime;
  final List<KeywordData> topKeywords;

  const InsightsData({
    required this.overallSentiment,
    required this.sentimentOverTime,
    required this.topKeywords,
  });

  factory InsightsData.fromJson(Map<String, dynamic> json) {
    final sentimentMap = <String, int>{};
    final rawSentiment = json['overall_sentiment'] as Map<String, dynamic>?;
    if (rawSentiment != null) {
      for (final entry in rawSentiment.entries) {
        final value = entry.value;
        if (value is num) {
          sentimentMap[entry.key] = value.toInt();
        }
      }
    }

    final rawSentimentOverTime = json['sentiment_over_time'] as List<dynamic>?;
    final sentimentOverTime = rawSentimentOverTime == null
        ? <SentimentTimeData>[]
        : rawSentimentOverTime
            .whereType<Map<String, dynamic>>()
            .map(SentimentTimeData.fromJson)
            .toList();

    final rawKeywords = json['top_keywords'] as List<dynamic>?;
    final topKeywords = rawKeywords == null
        ? <KeywordData>[]
        : rawKeywords
            .whereType<Map<String, dynamic>>()
            .map(KeywordData.fromJson)
            .toList();

    return InsightsData(
      overallSentiment: sentimentMap,
      sentimentOverTime: sentimentOverTime,
      topKeywords: topKeywords,
    );
  }
}
