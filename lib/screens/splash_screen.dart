import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/user_provider.dart';
import '../providers/leads_provider.dart';
import '../providers/property_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Ensuring the frame is rendered before starting heavy logic
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startInitialization();
    });
  }

  Future<void> _startInitialization() async {
    debugPrint("Splash: --- Initialization Cycle Started ---");

    try {
      // 1. Minimum branding time (2 seconds)
      // We do this concurrently with the Auth check to save time
      final delayFuture = Future.delayed(const Duration(seconds: 2));

      // 2. Wait for Firebase Auth to determine current session
      // Sometimes currentUser is null for a split second after boot.
      // firstWhere waits until we get a non-empty auth state.
      debugPrint("Splash: Waiting for Auth state...");
      final user = await FirebaseAuth.instance.authStateChanges().first.timeout(
        const Duration(seconds: 4),
        onTimeout: () => FirebaseAuth.instance.currentUser, // Fallback to current
      );

      debugPrint("Splash: Auth determined. User: ${user?.uid ?? 'None'}");

      // Wait for the branding delay to finish if it hasn't already
      await delayFuture;

      if (!mounted) return;

      if (user != null) {
        debugPrint("Splash: User detected. Syncing profile...");
        try {
          // Wrap the provider sync in a strict timeout
          // If Firestore is blocked by rules or network, we proceed anyway
          await context.read<UserProvider>().syncUserWithFirestore(user.uid).timeout(
            const Duration(seconds: 3),
            onTimeout: () {
              debugPrint("Splash: Sync timeout (3s). Proceeding with cache.");
            },
          );
        } catch (e) {
          debugPrint("Splash: Sync error caught: $e");
        }

        if (mounted) {
          debugPrint("Splash: Navigating to Home");
          await PropertyProvider().fetchProperties();
          await LeadProvider().fetchLeads(user.uid);
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        debugPrint("Splash: No user found. Navigating to Login");
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } catch (e) {
      debugPrint("Splash: Global Critical Error: $e");
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // We use a fixed height/width for the logo to prevent the "jump"
    // caused by relative MediaQuery calculations during hot reloads
    final logoSize = MediaQuery.of(context).size.width * 0.55;

    return Scaffold(
      backgroundColor: const Color(0xFF235F23),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF235F23),
              Color(0xFF06220E),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Using a fixed container to stabilize the logo
            SizedBox(
              width: logoSize,
              height: logoSize,
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high, // Smoother scaling
                errorBuilder: (context, error, stack) => const Icon(
                  Icons.business_center_rounded,
                  size: 80,
                  color: Colors.white24,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "WEPHCO",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            const Text(
              "BROKERAGE",
              style: TextStyle(
                color: Color(0xFFFED488),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 60),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Color(0xFFFED488),
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}