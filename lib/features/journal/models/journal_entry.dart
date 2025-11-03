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
  });

  final String id;
  final String? title;
  final String body;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? entryDate;
  final String? mood;
  final int? characterCount;

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    final content =
        (json['content'] as String?) ?? (json['body'] as String?) ?? '';

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
    );
  }
}
