import 'package:hive/hive.dart';

part 'wallet.g.dart';

@HiveType(typeId: 0)
class WalletInfo extends HiveObject {
  @HiveField(0)
  final double availableBalance;
  @HiveField(1)
  final double escrowBalance;
  @HiveField(2)
  final double totalEarnings;
  @HiveField(3)
  final String currency;

  WalletInfo({
    required this.availableBalance,
    required this.escrowBalance,
    required this.totalEarnings,
    required this.currency,
  });

  factory WalletInfo.fromMap(Map<String, dynamic> map) {
    return WalletInfo(
      availableBalance: (map['availableBalance'] as num).toDouble(),
      escrowBalance: (map['escrowBalance'] as num).toDouble(),
      totalEarnings: (map['totalEarnings'] as num).toDouble(),
      currency: map['currency'] ?? 'USD',
    );
  }

  WalletInfo copyWith({
    double? availableBalance,
    double? escrowBalance,
    double? totalEarnings,
    String? currency,
  }) {
    return WalletInfo(
      availableBalance: availableBalance ?? this.availableBalance,
      escrowBalance: escrowBalance ?? this.escrowBalance,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      currency: currency ?? this.currency,
    );
  }
}