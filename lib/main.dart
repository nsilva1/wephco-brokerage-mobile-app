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

// Providers
import './providers/user_provider.dart';

// Services
import 'package:wephco_brokerage/services/hive_service.dart';

// Config
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise Hive instance
  await HiveService.instance.init();

  // Register Adapters
  Hive.registerAdapter(LeadAdapter());
  Hive.registerAdapter(PropertyAdapter());
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(UserInfoAdapter());
  Hive.registerAdapter(WalletInfoAdapter());

  // Initialise Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider(),)
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
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(
        body: Center(child: Text('Wephco Brokerage'),),
      )
    );
  }
}

