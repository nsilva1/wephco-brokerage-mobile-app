import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/user_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
  // 1. Mandatory minimum display time for branding
  await Future.delayed(const Duration(seconds: 2));

  if (!mounted) return;

  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    try {
      // 2. Wrap the sync in a timeout (e.g., 5 seconds)
      // If the internet is slow, it will stop waiting and move to catch/finally
      await context.read<UserProvider>().syncUserWithFirestore(user.uid).timeout(
        const Duration(seconds: 5),
      );
    } catch (e) {
      // If it times out or fails, the Provider already has the Hive cache 
      // from its constructor, so we can safely proceed anyway.
      debugPrint("Sync timed out or failed, proceeding with cache.");
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  } else {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFF235F23),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Restricted logo size for better UI control
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.6, 
            child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
          ),
          const SizedBox(height: 40),
          Text("Wephco Brokerage", style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          const CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2, // Thinner looks more modern
          ),
        ],
      ),
    ),
  );
}
}