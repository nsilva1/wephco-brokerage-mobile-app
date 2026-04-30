import 'package:hive/hive.dart';

part 'user_settings.g.dart';

@HiveType(typeId: 7)
class UserSettings extends HiveObject {
  @HiveField(0)
  bool pushNotificationsEnabled;

  @HiveField(1)
  bool emailNotificationsEnabled;

  @HiveField(2)
  bool biometricEnabled;

  UserSettings({
    this.pushNotificationsEnabled = true,
    this.emailNotificationsEnabled = false,
    this.biometricEnabled = false,
  });

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      pushNotificationsEnabled: map['pushNotificationsEnabled'] as bool? ?? true,
      emailNotificationsEnabled: map['emailNotificationsEnabled'] as bool? ?? false,
      biometricEnabled: map['biometricEnabled'] as bool? ?? false,
    );
  }

  UserSettings copyWith({
    bool? pushNotificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? biometricEnabled,
  }) {
    return UserSettings(
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      emailNotificationsEnabled: emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    );
  }
}