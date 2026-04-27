import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wephco_brokerage/providers/user_provider.dart';
import 'package:wephco_brokerage/screens/dashboard.dart';
import 'package:wephco_brokerage/screens/leads/leads.dart';
import 'package:wephco_brokerage/screens/properties/properties.dart';
import 'package:wephco_brokerage/screens/wallet/wallet_screen.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;

  const MainLayout({super.key, this.initialIndex = 0});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout>
    with SingleTickerProviderStateMixin {
  late int _selectedIndex;
  bool _isFabOpen = false;
  late AnimationController _animationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fabAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  final List<Widget> _pages = [
    const HomeScreen(),
    const LeadsScreen(),
    const PropertiesScreen(),
    const WalletScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleFab() {
    setState(() {
      _isFabOpen = !_isFabOpen;
      if (_isFabOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _closeFab() {
    setState(() {
      _isFabOpen = false;
      _animationController.reverse();
    });
  }

  // Speed-dial menu items
  List<_SpeedDialItem> get _speedDialItems => [
        _SpeedDialItem(
          label: 'Logout',
          icon: Icons.logout,
          onTap: () {
            _closeFab();
            logout(context);
          },
        ),
        _SpeedDialItem(
          label: 'Profile',
          icon: Icons.person,
          onTap: () {
            _closeFab();
            Navigator.pushNamed(context, '/profile');
          },
        ),
        _SpeedDialItem(
          label: 'Settings',
          icon: Icons.settings,
          onTap: () {
            _closeFab();
            Navigator.pushNamed(context, '/settings');
          },
        ),
        _SpeedDialItem(
          label: 'KYC',
          icon: Icons.edit_document,
          onTap: () {
            _closeFab();
            Navigator.pushNamed(context, '/kyc');
          },
        ),
      ];

  @override
  Widget build(BuildContext context) {
    // final user = context.read<UserProvider>().currentUser;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Wephco Brokerage"),
          backgroundColor: const Color(0xFF064E3B),
          foregroundColor: Colors.white,
        ),

        body: Stack(
          children: [
            _pages[_selectedIndex],

            // Dim overlay when FAB is open
            if (_isFabOpen)
              GestureDetector(
                onTap: _closeFab,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                ),
              ),
          ],
        ),

        // --- Speed Dial FAB ---
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Speed dial items (animate in/out)
            ..._speedDialItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

              return AnimatedBuilder(
                animation: _fabAnimation,
                builder: (context, child) {
                  final delay = index * 0.15;
                  final animValue = Curves.easeOut.transform(
                    ((_fabAnimation.value - delay) / (1 - delay))
                        .clamp(0.0, 1.0),
                  );
                  return Opacity(
                    opacity: animValue,
                    child: Transform.translate(
                      offset: Offset(0, 10 * (1 - animValue)),
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Label chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Text(
                          item.label,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Mini FAB
                      FloatingActionButton.small(
                        heroTag: item.label,
                        onPressed: item.onTap,
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        child: Icon(item.icon, size: 18),
                      ),
                    ],
                  ),
                ),
              );
            }).toList().reversed,

            // Main FAB (rotates to X when open)
            FloatingActionButton(
              heroTag: 'main_fab',
              onPressed: _toggleFab,
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 4,
              child: _isFabOpen ? const Icon(Icons.close) : const Icon(Icons.menu),
            ),
          ],
        ),

        // --- The Bottom Navigation ---
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            _closeFab();
            _onItemTapped(index);
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard), label: "Dashboard"),
            BottomNavigationBarItem(
                icon: Icon(Icons.people), label: "Leads"),
            BottomNavigationBarItem(
                icon: Icon(Icons.business), label: "Properties"),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet), label: "Wallet"),
          ],
        ),
      ),
    );
  }
}

void logout(BuildContext context) {
  // Clear user data from provider
  context.read<UserProvider>().logout;

  // Navigate to login screen
  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
}
class _SpeedDialItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SpeedDialItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}