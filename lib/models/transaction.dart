import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'transaction.g.dart';

@HiveType(typeId: 1)
class Transaction extends HiveObject {
  @HiveField(0)
  final String? id;
  @HiveField(1)
  final String userId;
  @HiveField(2)
  final String? recipientId;
  @HiveField(3)
  final String? propertyId;
  @HiveField(4)
  final String type; // 'Deposit' | 'Withdrawal' | 'Income' | 'Escrow'
  @HiveField(5)
  final String transactionType; // 'Credit' | 'Debit'
  @HiveField(6)
  final double amount;
  @HiveField(7)
  final String status; // 'Pending' | 'Completed' | 'Failed'
  @HiveField(8)
  final String description;
  @HiveField(9)
  final DateTime? createdAt;

  Transaction({
    this.id,
    required this.userId,
    this.recipientId,
    this.propertyId,
    required this.type,
    required this.transactionType,
    required this.amount,
    required this.status,
    required this.description,
    this.createdAt,
  });

  factory Transaction.fromMap(Map<String, dynamic> map, [String? docId]) {
    return Transaction(
      id: docId ?? map['id'],
      userId: map['userId'] ?? '',
      recipientId: map['recipientId'],
      propertyId: map['propertyId'],
      type: map['type'] ?? 'Income',
      transactionType: map['transactionType'] ?? 'Credit',
      amount: (map['amount'] as num).toDouble(),
      status: map['status'] ?? 'Pending',
      description: map['description'] ?? '',
      createdAt: map['createdAt'] is Timestamp 
        ? (map['createdAt'] as Timestamp).toDate() 
        : null,
    );
  }
}