// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserInfoAdapter extends TypeAdapter<UserInfo> {
  @override
  final int typeId = 2;

  @override
  UserInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserInfo(
      id: fields[0] as String,
      email: fields[1] as String,
      name: fields[2] as String,
      role: fields[3] as String,
      commission: fields[4] as double,
      activeLeads: fields[5] as int,
      dealsClosed: fields[6] as int,
      wallet: fields[7] as WalletInfo,
      transactions: (fields[8] as List?)?.cast<Transaction>(),
      createdAt: fields[9] as String?,
      bankInfo: fields[10] as BankInfo?,
      status: fields[11] as String?,
      kycStatus: fields[12] as String?,
      kycFlagReason: fields[13] as String?,
      state: fields[14] as String?,
      city: fields[15] as String?,
      country: fields[16] as String?,
      address: fields[17] as String?,
      phone: fields[18] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserInfo obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.role)
      ..writeByte(4)
      ..write(obj.commission)
      ..writeByte(5)
      ..write(obj.activeLeads)
      ..writeByte(6)
      ..write(obj.dealsClosed)
      ..writeByte(7)
      ..write(obj.wallet)
      ..writeByte(8)
      ..write(obj.transactions)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.bankInfo)
      ..writeByte(11)
      ..write(obj.status)
      ..writeByte(12)
      ..write(obj.kycStatus)
      ..writeByte(13)
      ..write(obj.kycFlagReason)
      ..writeByte(14)
      ..write(obj.state)
      ..writeByte(15)
      ..write(obj.city)
      ..writeByte(16)
      ..write(obj.country)
      ..writeByte(17)
      ..write(obj.address)
      ..writeByte(18)
      ..write(obj.phone);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
