// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gamification_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GamificationProfileAdapter extends TypeAdapter<GamificationProfile> {
  @override
  final int typeId = 4;

  @override
  GamificationProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GamificationProfile(
      xp: fields[0] as int,
      level: fields[1] as int,
      currentStreak: fields[2] as int,
      highestStreak: fields[3] as int,
      lastCompletedDate: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, GamificationProfile obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.xp)
      ..writeByte(1)
      ..write(obj.level)
      ..writeByte(2)
      ..write(obj.currentStreak)
      ..writeByte(3)
      ..write(obj.highestStreak)
      ..writeByte(4)
      ..write(obj.lastCompletedDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GamificationProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
