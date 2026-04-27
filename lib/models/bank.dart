import 'package:hive/hive.dart';

part 'bank.g.dart';

@HiveType(typeId: 6)
class Bank extends HiveObject {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String code;
  

  Bank({
    required this.name,
    required this.code,
  });

  factory Bank.fromMap(Map<String, dynamic> map) {
    return Bank(
      name: map['name'] as String,
      code: map['code'] as String,
    );
  }

  Bank copyWith({String? name, String? code}) {
    return Bank(
      name: name ?? this.name,
      code: code ?? this.code,
    );
  }

}