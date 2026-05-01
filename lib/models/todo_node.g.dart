// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_node.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TodoNodeAdapter extends TypeAdapter<TodoNode> {
  @override
  final int typeId = 5;

  @override
  TodoNode read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TodoNode(
      id: fields[0] as String,
      name: fields[1] as String,
      children: (fields[2] as List).cast<TodoNode>(),
      isCompleted: fields[3] as bool,
      notes: fields[4] as String?,
      createdAt: fields[5] as DateTime,
      orderIndex: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TodoNode obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.children)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.orderIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoNodeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
