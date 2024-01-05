// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AddDataAdapter extends TypeAdapter<AddData> {
  @override
  final int typeId = 0;

  @override
  AddData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AddData(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as DateTime,
      fields[4] as String,
      fields[5] as String,
      fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AddData obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.IN)
      ..writeByte(3)
      ..write(obj.datetime)
      ..writeByte(4)
      ..write(obj.selectedItem)
      ..writeByte(5)
      ..write(obj.username)
      ..writeByte(6)
      ..write(obj.password);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
