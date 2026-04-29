import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'lead.g.dart';

@HiveType(typeId: 4)
class Lead extends HiveObject {
  @HiveField(0)
  final String? id;
  @HiveField(1)
  final String? name;
  @HiveField(2)
  final String? email;
  @HiveField(3)
  final String? phone;
  @HiveField(4)
  final String?userId;
  @HiveField(5)
  final String? propertyId;
  @HiveField(6)
  final double? budget;
  @HiveField(7)
  final String? source;
  @HiveField(8)
  final String? status;
  @HiveField(9)
  final DateTime? createdAt;
  @HiveField(10)
  final String? currency;
  @HiveField(11)
  final String? notes;

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
    required this.createdAt,
    required this.currency,
    this.notes,
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
      currency: map['currency'] ?? '',
      createdAt: map['createdAt'] is Timestamp 
        ? (map['createdAt'] as Timestamp).toDate() 
        : null,
      notes: map['notes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
  return {
    'name': name,
    'email': email,
    'phone': phone,
    'userId': userId,
    'propertyId': propertyId,
    'budget': budget,
    'source': source,
    'status': status,
    'createdAt': createdAt,
    'currency' : currency,
    'notes': notes,
  };
}

Lead copyWith({
  String? name,
  String? email,
  String? phone,
  String? userId,
  String? propertyId,
  double? budget,
  String? source,
  String? status,
  DateTime? createdAt,
  String? currency,
  String? notes,
}) {
  return Lead(
    id: id, // ID should not change on copy
    name: name ?? this.name,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    userId: userId ?? this.userId,
    propertyId: propertyId ?? this.propertyId,
    budget: budget ?? this.budget,
    source: source ?? this.source,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    currency: currency ?? this.currency,
    notes: notes ?? this.notes,
  );
}
}