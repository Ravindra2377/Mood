class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.body,
    required this.createdAt,
    this.title,
    this.updatedAt,
    this.entryDate,
    this.mood,
    this.characterCount,
    this.sentiment,
    this.sentimentScore,
    this.keywords = const <String>[],
  });

  final String id;
  final String? title;
  final String body;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? entryDate;
  final String? mood;
  final int? characterCount;
  final String? sentiment;
  final double? sentimentScore;
  final List<String> keywords;

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    final content =
        (json['content'] as String?) ?? (json['body'] as String?) ?? '';
    final rawKeywords = json['keywords'];
    final parsedKeywords = _parseKeywords(rawKeywords);
    final rawScore = json['sentiment_score'];

    return JournalEntry(
      id: (json['id'] ?? '').toString(),
      title: json['title'] as String?,
      body: content,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      entryDate: json['entry_date'] != null
          ? DateTime.parse(json['entry_date'] as String)
          : null,
      mood: json['mood'] as String?,
      characterCount: json['character_count'] as int?,
      sentiment: json['sentiment'] as String?,
      sentimentScore: rawScore is num
          ? rawScore.toDouble()
          : rawScore is String
              ? double.tryParse(rawScore)
              : null,
      keywords: List<String>.unmodifiable(parsedKeywords),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': body,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt?.toIso8601String(),
      if (entryDate != null) 'entry_date': entryDate?.toIso8601String(),
      if (mood != null) 'mood': mood,
      if (characterCount != null) 'character_count': characterCount,
      if (sentiment != null) 'sentiment': sentiment,
      if (sentimentScore != null) 'sentiment_score': sentimentScore,
      if (keywords.isNotEmpty) 'keywords': List<String>.from(keywords),
    };
  }

  JournalEntry copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? entryDate,
    String? mood,
    int? characterCount,
    String? sentiment,
    double? sentimentScore,
    List<String>? keywords,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      entryDate: entryDate ?? this.entryDate,
      mood: mood ?? this.mood,
      characterCount: characterCount ?? this.characterCount,
      sentiment: sentiment ?? this.sentiment,
      sentimentScore: sentimentScore ?? this.sentimentScore,
      keywords: keywords != null
          ? List<String>.unmodifiable(keywords)
          : this.keywords,
    );
  }

  static List<String> _parseKeywords(dynamic rawKeywords) {
    if (rawKeywords is List) {
      return rawKeywords
          .whereType<String>()
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList(growable: false);
    }
    if (rawKeywords is String) {
      return rawKeywords
          .split(',')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList(growable: false);
    }
    return const <String>[];
  }
}
