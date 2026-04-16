// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lead.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LeadAdapter extends TypeAdapter<Lead> {
  @override
  final int typeId = 4;

  @override
  Lead read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Lead(
      id: fields[0] as String?,
      name: fields[1] as String?,
      email: fields[2] as String?,
      phone: fields[3] as String?,
      userId: fields[4] as String?,
      propertyId: fields[5] as String?,
      budget: fields[6] as double?,
      source: fields[7] as String?,
      status: fields[8] as String?,
      createdAt: fields[9] as DateTime?,
      currency: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Lead obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.userId)
      ..writeByte(5)
      ..write(obj.propertyId)
      ..writeByte(6)
      ..write(obj.budget)
      ..writeByte(7)
      ..write(obj.source)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.currency);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeadAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
