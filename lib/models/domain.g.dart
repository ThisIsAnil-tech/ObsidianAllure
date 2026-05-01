// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'domain.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DomainModelAdapter extends TypeAdapter<DomainModel> {
  @override
  final int typeId = 1;

  @override
  DomainModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DomainModel(
      id: fields[0] as String,
      name: fields[1] as String,
      subtopics: (fields[2] as List).cast<Subtopic>(),
      createdAt: fields[4] as DateTime,
      colorIndex: fields[3] as int,
      orderIndex: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DomainModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.subtopics)
      ..writeByte(3)
      ..write(obj.colorIndex)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.orderIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DomainModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
