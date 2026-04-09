import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wephco_brokerage/providers/user_provider.dart';
import 'package:wephco_brokerage/screens/dashboard.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  // 1. Define your pages here
  final List<Widget> _pages = [
    const Dashboard(),
    const Center(child: Text("Leads Page", style: TextStyle(fontSize: 24))),
    const Center(child: Text("Properties Page", style: TextStyle(fontSize: 24))),
    const Center(child: Text("Wallet Page", style: TextStyle(fontSize: 24))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<UserProvider>().currentUser;

    return SafeArea(child: Scaffold(
      // --- The Top Bar ---
      appBar: AppBar(
        title: const Text("Wephco Brokerage"),
        backgroundColor: const Color(0xFF235F23),
        foregroundColor: Colors.white,
      ),

      // --- The Side Drawer ---
      drawer: Drawer(
  child: Column( // Use a Column instead of just a ListView
    children: [
      // 1. The Scrollable Area
      Expanded(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF235F23)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Color(0xFF235F23)),
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
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
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
        leading: const Icon(Icons.logout, color: Colors.red),
        title: const Text("Logout", style: TextStyle(color: Colors.red)),
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

      // --- The Bottom Navigation ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Essential for 4+ items
        selectedItemColor: const Color(0xFF235F23),
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