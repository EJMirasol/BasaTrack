// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReadingTaskAdapter extends TypeAdapter<ReadingTask> {
  @override
  final int typeId = 0;

  @override
  ReadingTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReadingTask(
      id: fields[0] as String,
      reference: fields[1] as String,
      isCompleted: fields[2] as bool,
      completedAt: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ReadingTask obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.reference)
      ..writeByte(2)
      ..write(obj.isCompleted)
      ..writeByte(3)
      ..write(obj.completedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
