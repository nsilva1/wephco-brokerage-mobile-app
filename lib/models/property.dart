import 'package:hive/hive.dart';

part 'property.g.dart';

@HiveType(typeId: 3)
class Property extends HiveObject {
  @HiveField(0)
  final String? id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String developer;
  @HiveField(3)
  final String location;
  @HiveField(4)
  final double price;
  @HiveField(5)
  final double? yieldValue; // 'yield' is a reserved keyword in Dart
  @HiveField(6)
  final String status;
  @HiveField(7)
  final String description;
  @HiveField(8)
  final String image;
  @HiveField(9)
  final String? createdAt;

  Property({
    this.id,
    required this.title,
    required this.developer,
    required this.location,
    required this.price,
    this.yieldValue,
    required this.status,
    required this.description,
    required this.image,
    this.createdAt,
  });

  factory Property.fromMap(Map<String, dynamic> map, [String? docId]) {
    return Property(
      id: docId ?? map['id'],
      title: map['title'] ?? '',
      developer: map['developer'] ?? '',
      location: map['location'] ?? '',
      price: (map['price'] as num).toDouble(),
      yieldValue: map['yield'] != null ? (map['yield'] as num).toDouble() : null,
      status: map['status'] ?? 'New Launch',
      description: map['description'] ?? '',
      image: map['image'] ?? '',
      createdAt: map['createdAt'],
    );
  }
}