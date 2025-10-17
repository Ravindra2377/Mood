import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class JournalEntry extends HiveObject {
  @HiveField(0)
  String id; // use uuid or server id

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  String mood;

  @HiveField(4)
  List<String> attachments;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  @HiveField(7)
  bool synced;

  JournalEntry({
    required this.id,
    this.title = '',
    this.content = '',
    this.mood = 'neutral',
    List<String>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.synced = false,
  })  : attachments = attachments ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();
}
