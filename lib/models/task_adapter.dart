import 'package:hive/hive.dart';

import 'task.dart';


class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      title: fields[0] as String,
      date: fields[1] as DateTime,
      isDone: fields[2] as bool? ?? false,
      description: fields[3] as String? ?? '',
      category: fields[4] as String? ?? 'General',
      priority: fields[5] as String? ?? 'Medium',
      timeMinutes: fields[6] as int?,
      location: fields[7] as String? ?? '',
      assignedTo: fields[8] as String? ?? '',
      durationMinutes: fields[9] as int? ?? 0,
      tags: fields[10] as String? ?? '',
      reminder: fields[11] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.isDone)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.priority)
      ..writeByte(6)
      ..write(obj.timeMinutes)
      ..writeByte(7)
      ..write(obj.location)
      ..writeByte(8)
      ..write(obj.assignedTo)
      ..writeByte(9)
      ..write(obj.durationMinutes)
      ..writeByte(10)
      ..write(obj.tags)
      ..writeByte(11)
      ..write(obj.reminder);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
