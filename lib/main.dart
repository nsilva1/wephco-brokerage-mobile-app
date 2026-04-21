import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// Models
import 'package:wephco_brokerage/models/lead.dart';
import 'package:wephco_brokerage/models/property.dart';
import 'package:wephco_brokerage/models/transaction.dart';
import 'package:wephco_brokerage/models/user.dart';
import 'package:wephco_brokerage/models/wallet.dart';
import 'package:wephco_brokerage/screens/leads/add_lead.dart';

// Providers
import './providers/user_provider.dart';
import './providers/property_provider.dart';
import './providers/leads_provider.dart';

// Services
import 'package:wephco_brokerage/services/hive_service.dart';

// Config
import 'firebase_options.dart';

// Screens
import 'package:wephco_brokerage/screens/splash_screen.dart';
import 'package:wephco_brokerage/screens/auth/login.dart';
import 'package:wephco_brokerage/screens/auth/register.dart';
import 'package:wephco_brokerage/screens/main_layout.dart';
import 'package:wephco_brokerage/screens/properties/property_details.dart';
import 'package:wephco_brokerage/screens/wallet/wallet_transaction_history.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();


  // Register Adapters
  Hive.registerAdapter(LeadAdapter());
  Hive.registerAdapter(PropertyAdapter());
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(UserInfoAdapter());
  Hive.registerAdapter(WalletInfoAdapter());

  // Initialise Hive instance
  await HiveService.instance.init();

  // Initialise Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        colorScheme: .fromSeed(
          seedColor: const Color(0xFF064E3B),
          primary: const Color(0xFF064E3B),
          secondary: const Color(0xFFC5A059)
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const MainLayout(),
        '/leads': (context) => const MainLayout(initialIndex: 1,),
        '/properties': (context) => const MainLayout(initialIndex: 2,),
        '/wallet': (context) => const MainLayout(initialIndex: 3,),
        '/properties/detail': (context) => const PropertyDetails(),
        '/leads/new': (context) => const AddLeadScreen(),
        '/wallet/transactions': (context) => WalletTransactionHistory()
      },
    );
  }
}

