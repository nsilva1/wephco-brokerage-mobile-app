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

class _MainLayoutState extends State<MainLayout> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    // Initialize the index based on what was passed to the widget
    _selectedIndex = widget.initialIndex;
  }

  // 1. Define your pages here
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

  // Helper to determine FAB action based on current tab
  void _handleFabPressed() {
    switch (_selectedIndex) {
      case 0: // Dashboard
      case 1: // Leads
        Navigator.pushNamed(context, '/leads/new');
        break;
      case 2: // Properties
        Navigator.pushNamed(context, '/properties/new');
        break;
      case 3: // Wallet
        print('Navigating to Withdrawal/Transaction Screen');
        break;
    }
  }

  // Helper to determine FAB icon
  IconData _getFabIcon() {
    switch (_selectedIndex) {
      case 2:
        return Icons.add_business;
      case 3:
        return Icons.add_card;
      default:
        return Icons.person_add_alt_1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<UserProvider>().currentUser;

    return SafeArea(child: Scaffold(
      appBar: AppBar(
        title: const Text("Wephco Brokerage"),
        backgroundColor: const Color(0xFF064E3B),
        foregroundColor: Colors.white,
      ),

      // --- The Side Drawer ---
      drawer: Drawer(
        backgroundColor: Theme.of(context).colorScheme.primary,
  child: Column( // Use a Column instead of just a ListView
    children: [
      // 1. The Scrollable Area
      Expanded(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Color(0xFF064E3B)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user!.name,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user.email,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              iconColor: Theme.of(context).colorScheme.secondary,
              textColor: Theme.of(context).colorScheme.secondary,
              leading: const Icon(Icons.edit_document),
              title: const Text("KYC"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              iconColor: Theme.of(context).colorScheme.secondary,
              textColor: Theme.of(context).colorScheme.secondary,
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              iconColor: Theme.of(context).colorScheme.secondary,
              textColor: Theme.of(context).colorScheme.secondary,
              leading: const Icon(Icons.help_outline),
              title: const Text("Support"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),

      // 2. The Permanent Bottom Area
      const Divider(height: 1), // Optional: clean line above logout
      ListTile(
        leading: const Icon(Icons.logout, color: Colors.grey),
        title: const Text("Logout", style: TextStyle(color: Colors.grey)),
        onTap: () {
          // Trigger your logout logic
          // _handleLogout(context);
          print('logout tapped');
        },
      ),
      // Optional: Add a little padding at the bottom for modern phones (Safe Area)
      const SizedBox(height: 20), 
    ],
  ),
),

      // --- The Dynamic Body ---
      body: _pages[_selectedIndex],

      // --- Floating Action Button ---
        floatingActionButton: FloatingActionButton(
          onPressed: _handleFabPressed,
          backgroundColor: const Color(0xFF064E3B),
          foregroundColor: Colors.white,
          elevation: 4,
          child: Icon(_getFabIcon()),
        ),

      // --- The Bottom Navigation ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Essential for 4+ items
        selectedItemColor: const Color(0xFF064E3B),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Leads"),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: "Properties"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: "Wallet"),
        ],
      ),
    ));
  }
}