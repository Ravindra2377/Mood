import 'package:hive/hive.dart';
import 'journal_entry.dart';

class JournalEntryAdapter extends TypeAdapter<JournalEntry> {
  @override
  final int typeId = 1;

  @override
  JournalEntry read(BinaryReader reader) {
    final numFields = reader.readByte();
    final Map<int, dynamic> fields = {};
    for (var i = 0; i < numFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return JournalEntry(
      id: fields[0] as String,
      title: fields[1] as String,
      content: fields[2] as String,
      mood: fields[3] as String,
      attachments: (fields[4] as List?)?.cast<String>(),
      createdAt: fields[5] as DateTime?,
      updatedAt: fields[6] as DateTime?,
      synced: fields[7] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, JournalEntry obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.mood)
      ..writeByte(4)
      ..write(obj.attachments)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.synced);
  }
}
