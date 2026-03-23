import 'package:hive/hive.dart';

part 'lead.g.dart';

@HiveType(typeId: 4)
class Lead extends HiveObject {
  @HiveField(0)
  final String? id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final String phone;
  @HiveField(4)
  final String userId;
  @HiveField(5)
  final String propertyId;
  @HiveField(6)
  final double? budget;
  @HiveField(7)
  final String source;
  @HiveField(8)
  final String status;
  @HiveField(9)
  final String? createdAt;

  Lead({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.userId,
    required this.propertyId,
    this.budget,
    required this.source,
    required this.status,
    this.createdAt,
  });

  factory Lead.fromMap(Map<String, dynamic> map, [String? docId]) {
    return Lead(
      id: docId ?? map['id'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      userId: map['userId'] ?? '',
      propertyId: map['propertyId'] ?? '',
      budget: map['budget'] != null ? (map['budget'] as num).toDouble() : null,
      source: map['source'] ?? '',
      status: map['status'] ?? 'New Lead',
      createdAt: map['createdAt'],
    );
  }
}