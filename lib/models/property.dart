import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final double? yieldValue;
  @HiveField(6)
  final String status;
  @HiveField(7)
  final String description;
  @HiveField(8)
  final List<String> images;
  @HiveField(9)
  final DateTime? createdAt;
  @HiveField(10)
  final String currency;
  @HiveField(11)
  final String tag;
  @HiveField(12)
  final String pdfUrl;
  @HiveField(13)
  final DateTime? updatedAt;
  @HiveField(14)
  final String category;
  @HiveField(15)
  final bool verified;
  @HiveField(16)
  final List<String> interests;

  Property({
    this.id,
    required this.title,
    required this.developer,
    required this.location,
    required this.price,
    this.yieldValue,
    required this.status,
    required this.description,
    required this.images,
    this.createdAt,
    required this.currency,
    required this.tag,
    required this.pdfUrl,
    this.updatedAt,
    required this.category,
    required this.verified,
    this.interests = const [],
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
      images: List<String>.from(map['images'] ?? []),
      currency: map['currency'] ?? '',
      createdAt: map['createdAt'] is Timestamp 
        ? (map['createdAt'] as Timestamp).toDate() 
        : null,
      tag: map['tag'] ?? '',
      pdfUrl: map['pdfUrl'] ?? '',
      updatedAt: map['updatedAt'] is Timestamp 
        ? (map['updatedAt'] as Timestamp).toDate() 
        : null,
        category: map['category'] ?? '',
        verified: map['verified'] ?? false,
        interests: List<String>.from(map['interests'] ?? []),
    );
  }

  Property copyWith({
    String? id,
    String? title,
    String? developer,
    String? location,
    double? price,
    double? yieldValue,
    String? status,
    String? description,
    List<String>? images,
    DateTime? createdAt,
    String? currency,
    String? tag,
    String? pdfUrl,
    DateTime? updatedAt,
    String? category,
    bool? verified,
    List<String>? interests,
  }) {
    return Property(
      id: id ?? this.id,
      title: title ?? this.title,
      developer: developer ?? this.developer,
      location: location ?? this.location,
      price: price ?? this.price,
      yieldValue: yieldValue ?? this.yieldValue,
      status: status ?? this.status,
      description: description ?? this.description,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      currency: currency ?? this.currency,
      tag: tag ?? this.tag,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      verified: verified ?? this.verified,
      interests: interests ?? this.interests,
    );
  }
}