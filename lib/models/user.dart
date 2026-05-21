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
  @HiveField(11)
  final String? status;
  @HiveField(12)
  final String? kycStatus;
  @HiveField(13)
  final String? kycFlagReason;
  @HiveField(14)
  final String? state;
  @HiveField(15)
  final String? city;
  @HiveField(16)
  final String? country;
  @HiveField(17)
  final String? address;
  @HiveField(18)
  final String phone;

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
    this.status,
    this.kycStatus,
    this.kycFlagReason,
    required this.state,
    required this.city,
    required this.country,
    required this.address,
    required this.phone,
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
      status: map['status'] ?? 'Active',
      kycStatus: map['kycStatus'] ?? 'pending',
      kycFlagReason: map['kycFlagReason'] ?? '',
      state: map['state'] ?? '',
      city: map['city'] ?? '',
      country: map['country'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
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
    String? status,
    String? kycStatus,
    String? kycFlagReason,
    String? state,
    String? city,
    String? country,
    String? address,
    String? phone,
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
      status: status ?? this.status,
      kycStatus: kycStatus ?? this.kycStatus,
      kycFlagReason: kycFlagReason ?? this.kycFlagReason,
      state: state ?? this.state,
      city: city ?? this.city,
      country: country ?? this.country,
      address: address ?? this.address,
      phone: phone ?? this.phone,
    );
  }
}