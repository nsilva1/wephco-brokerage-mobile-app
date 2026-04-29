import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

// Models
import 'package:wephco_brokerage/models/lead.dart';
import 'package:wephco_brokerage/models/property.dart';
import 'package:wephco_brokerage/models/transaction.dart';
import 'package:wephco_brokerage/models/user.dart';
import 'package:wephco_brokerage/models/wallet.dart';
import 'package:wephco_brokerage/screens/leads/add_lead.dart';
import 'package:wephco_brokerage/models/bank_info.dart';
import 'package:wephco_brokerage/models/bank.dart';


// Providers
import './providers/user_provider.dart';
import './providers/property_provider.dart';
import './providers/leads_provider.dart';

// Services
import 'package:wephco_brokerage/services/hive_service.dart';
import 'package:wephco_brokerage/services/notification_service.dart';

// Config
import 'package:wephco_brokerage/firebase_options.dart';
import 'package:wephco_brokerage/utils/navigator_key.dart';
import 'package:wephco_brokerage/utils/auth_guard.dart';

// Screens
import 'package:wephco_brokerage/screens/splash_screen.dart';
import 'package:wephco_brokerage/screens/auth/login.dart';
import 'package:wephco_brokerage/screens/auth/register.dart';
import 'package:wephco_brokerage/screens/main_layout.dart';
import 'package:wephco_brokerage/screens/properties/property_details.dart';
import 'package:wephco_brokerage/screens/wallet/wallet_transaction_history.dart';
import 'package:wephco_brokerage/screens/sidebar/kyc.dart';
import 'package:wephco_brokerage/screens/sidebar/profile.dart';
import 'package:wephco_brokerage/screens/sidebar/settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();


  // Register Adapters
  Hive.registerAdapter(LeadAdapter());
  Hive.registerAdapter(PropertyAdapter());
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(UserInfoAdapter());
  Hive.registerAdapter(WalletInfoAdapter());
  Hive.registerAdapter(BankInfoAdapter());
  Hive.registerAdapter(BankAdapter());

  // Initialise Hive instance
  await HiveService.instance.init();

  // Initialise Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    // appleProvider: AppleProvider.appAttest,
    // providerAndroid: AndroidAppCheckProvider
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  await NotificationService.instance.initialize();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider(),),
        ChangeNotifierProvider(create: (_) => PropertyProvider()),
        ChangeNotifierProvider(create: (_) => LeadProvider()),
      ],
      child: const MyApp()
    )
  );

  await NotificationService.instance.handleInitialMessage();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wephco Brokerage',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF064E3B),
          primary: const Color(0xFF064E3B),
          secondary: const Color(0xFFC5A059)
        ),
      ),
      navigatorKey: navigatorKey,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const AuthGuard(child: MainLayout()),
        '/leads': (context) => const AuthGuard(child: MainLayout(initialIndex: 1,)),
        '/properties': (context) => const AuthGuard(child: MainLayout(initialIndex: 2,)),
        '/wallet': (context) => const AuthGuard(child: MainLayout(initialIndex: 3,)),
        '/properties/detail': (context) => const AuthGuard(child: PropertyDetails()),
        '/leads/new': (context) => const AuthGuard(child: AddLeadScreen()),
        '/wallet/transactions': (context) => const AuthGuard(child: WalletTransactionHistory()),
        '/kyc': (context) => const AuthGuard(child: KYCScreen()),
        '/profile': (context) => const AuthGuard(child: ProfileScreen()),
        '/settings': (context) => const AuthGuard(child: SettingsScreen()),
      },
    );
  }
}

