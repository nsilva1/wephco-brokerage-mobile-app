// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WalletInfoAdapter extends TypeAdapter<WalletInfo> {
  @override
  final int typeId = 0;

  @override
  WalletInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WalletInfo(
      availableBalance: fields[0] as double,
      escrowBalance: fields[1] as double,
      totalEarnings: fields[2] as double,
      currency: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WalletInfo obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.availableBalance)
      ..writeByte(1)
      ..write(obj.escrowBalance)
      ..writeByte(2)
      ..write(obj.totalEarnings)
      ..writeByte(3)
      ..write(obj.currency);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
