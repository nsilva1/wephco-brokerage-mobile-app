import 'package:hive/hive.dart';

part 'bank_info.g.dart';

@HiveType(typeId: 5)
class BankInfo extends HiveObject {
  @HiveField(0)
  final String bankName;
  @HiveField(1)
  final int? bankAccountNumber;
  @HiveField(2)
  final String bankAccountName;
  @HiveField(3)
  final int? nin;
  @HiveField(4)
  final int? bvn;
  @HiveField(5)
  final String bankCode;

  BankInfo({
    this.bankName = '',
    this.bankAccountNumber,
    this.bankAccountName = '',
    this.nin,
    this.bvn,
    this.bankCode = '',
  });

  factory BankInfo.fromMap(Map<String, dynamic> map) {
    return BankInfo(
      bankName: map['bankName'] as String? ?? '',
      bankAccountNumber: map['bankAccountNumber'] as int?,
      bankAccountName: map['bankAccountName'] as String? ?? '',
      nin: map['nin'] as int?,
      bvn: map['bvn'] as int?,
      bankCode: map['bankCode'] as String? ?? '',
    );
  }

  BankInfo copyWith({
    int? nin,
    int? bvn,
    String? bankName,
    int? bankAccountNumber,
    String? bankAccountName,
    String? bankCode,
  }) {
    return BankInfo(
      nin: nin ?? this.nin,
      bvn: bvn ?? this.bvn,
      bankName: bankName ?? this.bankName,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankAccountName: bankAccountName ?? this.bankAccountName,
      bankCode: bankCode ?? this.bankCode,
    );
  }
}