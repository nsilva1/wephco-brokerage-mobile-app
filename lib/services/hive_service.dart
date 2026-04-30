import 'package:hive_flutter/hive_flutter.dart';
import '../models/lead.dart';
import '../models/property.dart';
import '../models/transaction.dart';
import '../models/user.dart';
import '../models/wallet.dart';
import '../models/user_settings.dart';

class HiveService {
  // Private constructor
  HiveService._internal();

  // Create single instance
  static final HiveService _instance = HiveService._internal();

  // Getter to access the instance
  static HiveService get instance => _instance;

  // Reference to all model boxes
  late Box<UserInfo> userBox;
  late Box<Property> propertyBox;
  late Box<Lead> leadBox;
  late Box<Transaction> transactionBox;
  late Box<WalletInfo> walletBox;
  late Box<UserSettings> userSettingsBox;
  
  // Initialize everything
  Future<void> init() async {
    // await Hive.initFlutter();

    // open all boxes
    userBox = await Hive.openBox<UserInfo>('userBox');
    propertyBox = await Hive.openBox<Property>('propertyBox');
    leadBox = await Hive.openBox<Lead>('leadBox');
    transactionBox = await Hive.openBox<Transaction>('transactionBox');
    walletBox = await Hive.openBox<WalletInfo>('walletBox');
    userSettingsBox = await Hive.openBox<UserSettings>('userSettingsBox');
  }

  UserInfo? get currentUser => userBox.get('current_session');
  UserSettings get settings => userSettingsBox.get('settings') ?? UserSettings();

  Future<void> saveUser(UserInfo user) async {
    await userBox.put('current_session', user);
  }

  Future<void> saveSettings(UserSettings settings) async {
    await userSettingsBox.put('settings', settings);
  }

  Future<void> saveAllProperties(List<Property> properties) async {
    final map = {for (var p in properties) p.id! : p};
    await propertyBox.putAll(map);
  }

  Future<void> saveAllLeads(List<Lead> leads) async {
    final map = {for (var l in leads) l.id! : l};
    await leadBox.putAll(map);
  }

  List<Property> get allCachedProperties => propertyBox.values.toList();

  List<Lead> get allCachedLeads => leadBox.values.toList();

  Future<void> clearAll() async {
    await userBox.clear();
    await propertyBox.clear();
    await leadBox.clear();
    await transactionBox.clear();
    await walletBox.clear();
    await userSettingsBox.clear();
  }
}