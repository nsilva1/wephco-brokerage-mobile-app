import 'package:hive/hive.dart';
import 'wallet.dart';
import 'transaction.dart';

part 'user.g.dart';

@HiveType(typeId: 2)
class UserInfo extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String email;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final String role;
  @HiveField(4)
  final double commision;
  @HiveField(5)
  final int activeLeads;
  @HiveField(6)
  final int dealsClosed;
  @HiveField(7)
  final WalletInfo wallet;
  @HiveField(8)
  final List<Transaction> transactions;
  @HiveField(9)
  final String? createdAt;

  UserInfo({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.commision,
    required this.activeLeads,
    required this.dealsClosed,
    required this.wallet,
    required this.transactions,
    this.createdAt,
  });

  factory UserInfo.fromMap(Map<String, dynamic> map, String docId) {
    return UserInfo(
      id: docId,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'Agent',
      commision: (map['commision'] as num? ?? 0).toDouble(),
      activeLeads: map['activeLeads'] ?? 0,
      dealsClosed: map['dealsClosed'] ?? 0,
      wallet: WalletInfo.fromMap(map['wallet'] ?? {}),
      transactions: (map['transactions'] as List? ?? [])
          .map((t) => Transaction.fromMap(t))
          .toList(),
      createdAt: map['createdAt'],
    );
  }
}