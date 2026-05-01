// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subtopic.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubtopicAdapter extends TypeAdapter<Subtopic> {
  @override
  final int typeId = 2;

  @override
  Subtopic read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Subtopic(
      id: fields[0] as String,
      name: fields[1] as String,
      topics: (fields[2] as List).cast<Topic>(),
      createdAt: fields[3] as DateTime,
      orderIndex: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Subtopic obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.topics)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.orderIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubtopicAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
