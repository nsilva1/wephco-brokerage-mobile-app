// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PropertyAgentAdapter extends TypeAdapter<PropertyAgent> {
  @override
  final int typeId = 8;

  @override
  PropertyAgent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PropertyAgent(
      name: fields[0] as String,
      email: fields[1] as String,
      phone: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PropertyAgent obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.phone);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PropertyAgentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PropertyUnitAdapter extends TypeAdapter<PropertyUnit> {
  @override
  final int typeId = 9;

  @override
  PropertyUnit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PropertyUnit(
      bedroom: fields[0] as String,
      bathroom: fields[1] as String,
      squareFoot: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PropertyUnit obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.bedroom)
      ..writeByte(1)
      ..write(obj.bathroom)
      ..writeByte(2)
      ..write(obj.squareFoot);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PropertyUnitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PropertyAdapter extends TypeAdapter<Property> {
  @override
  final int typeId = 3;

  @override
  Property read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Property(
      id: fields[0] as String?,
      title: fields[1] as String,
      developer: fields[2] as String,
      location: fields[3] as String,
      price: fields[4] as double,
      yieldValue: fields[5] as double?,
      status: fields[6] as String,
      description: fields[7] as String,
      images: (fields[8] as List).cast<String>(),
      createdAt: fields[9] as DateTime?,
      currency: fields[10] as String,
      tag: fields[11] as String,
      pdfUrl: fields[12] as String,
      updatedAt: fields[13] as DateTime?,
      category: fields[14] as String,
      verified: fields[15] as bool,
      interests: (fields[16] as List).cast<String>(),
      googleMapLocation: fields[17] == null ? '' : fields[17] as String,
      bedroom: fields[18] == null ? [] : (fields[18] as List).cast<String>(),
      bathroom: fields[19] == null ? [] : (fields[19] as List).cast<String>(),
      squareFoot: fields[20] == null ? [] : (fields[20] as List).cast<String>(),
      units:
          fields[21] == null ? [] : (fields[21] as List).cast<PropertyUnit>(),
      featured: fields[22] == null ? false : fields[22] as bool,
      agent: fields[23] as PropertyAgent?,
      developerId: fields[24] == null ? '' : fields[24] as String,
      views: fields[25] == null ? 0 : fields[25] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Property obj) {
    writer
      ..writeByte(26)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.developer)
      ..writeByte(3)
      ..write(obj.location)
      ..writeByte(4)
      ..write(obj.price)
      ..writeByte(5)
      ..write(obj.yieldValue)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.images)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.currency)
      ..writeByte(11)
      ..write(obj.tag)
      ..writeByte(12)
      ..write(obj.pdfUrl)
      ..writeByte(13)
      ..write(obj.updatedAt)
      ..writeByte(14)
      ..write(obj.category)
      ..writeByte(15)
      ..write(obj.verified)
      ..writeByte(16)
      ..write(obj.interests)
      ..writeByte(17)
      ..write(obj.googleMapLocation)
      ..writeByte(18)
      ..write(obj.bedroom)
      ..writeByte(19)
      ..write(obj.bathroom)
      ..writeByte(20)
      ..write(obj.squareFoot)
      ..writeByte(21)
      ..write(obj.units)
      ..writeByte(22)
      ..write(obj.featured)
      ..writeByte(23)
      ..write(obj.agent)
      ..writeByte(24)
      ..write(obj.developerId)
      ..writeByte(25)
      ..write(obj.views);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PropertyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
