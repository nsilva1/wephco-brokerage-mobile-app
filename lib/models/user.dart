import 'package:hive/hive.dart';
import 'wallet.dart';
import 'transaction.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'bank_info.dart';


part 'user.g.dart';

class _Undefined {
  const _Undefined();
}

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
  final double commission;
  @HiveField(5)
  final int activeLeads;
  @HiveField(6)
  final int dealsClosed;
  @HiveField(7)
  final WalletInfo wallet;
  @HiveField(8)
  final List<Transaction>? transactions;
  @HiveField(9)
  final String? createdAt;
  @HiveField(10)
  final BankInfo? bankInfo;

  UserInfo({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.commission,
    required this.activeLeads,
    required this.dealsClosed,
    required this.wallet,
    required this.transactions,
    this.createdAt,
    this.bankInfo,
  });

  factory UserInfo.fromMap(Map<String, dynamic> map, String docId) {
    return UserInfo(
      id: docId,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'Agent',
      commission: (map['commission'] as num? ?? 0).toDouble(),
      activeLeads: map['activeLeads'] ?? 0,
      dealsClosed: map['dealsClosed'] ?? 0,
      wallet: WalletInfo.fromMap(map['wallet'] ?? {}),
      transactions: (map['transactions'] as List? ?? [])
          .map((t) => Transaction.fromMap(t))
          .toList(),
      createdAt: map['createdAt'] is Timestamp 
        ? (map['createdAt'] as Timestamp).toDate().toString() 
        : null,
      bankInfo: map['bankInfo'] != null 
    ? BankInfo.fromMap(map['bankInfo'] as Map<String, dynamic>) 
    : null,
    );
  }

  UserInfo copyWith({
    String? email,
    String? name,
    String? role,
    double? commission,
    int? activeLeads,
    int? dealsClosed,
    WalletInfo? wallet,
    List<Transaction>? transactions,
    Object? bankInfo = const _Undefined(),
  }) {
    return UserInfo(
      id: id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      commission: commission ?? this.commission,
      activeLeads: activeLeads ?? this.activeLeads,
      dealsClosed: dealsClosed ?? this.dealsClosed,
      wallet: wallet ?? this.wallet,
      transactions: transactions ?? this.transactions,
      createdAt: createdAt,
      bankInfo: bankInfo is _Undefined ? this.bankInfo : bankInfo as BankInfo?,
    );
  }
}