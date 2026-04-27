// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bank_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BankInfoAdapter extends TypeAdapter<BankInfo> {
  @override
  final int typeId = 5;

  @override
  BankInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BankInfo(
      bankName: fields[0] as String,
      bankAccountNumber: fields[1] as int?,
      bankAccountName: fields[2] as String,
      nin: fields[3] as int?,
      bvn: fields[4] as int?,
      bankCode: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, BankInfo obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.bankName)
      ..writeByte(1)
      ..write(obj.bankAccountNumber)
      ..writeByte(2)
      ..write(obj.bankAccountName)
      ..writeByte(3)
      ..write(obj.nin)
      ..writeByte(4)
      ..write(obj.bvn)
      ..writeByte(5)
      ..write(obj.bankCode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BankInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
