import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wephco_brokerage/providers/leads_provider.dart';
import 'package:wephco_brokerage/providers/user_provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    final user = context.read<UserProvider>().currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("Welcome, ${user?.name}", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 50),
            _statCards(),
            const SizedBox(height: 50),
            _cta(),
            const SizedBox(height: 50,),
            Text("Active Leads", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 30,),
            _leadsListView(),
          ],
        ),
      );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF235F23),
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // 1. Background Decoration Icon
            Positioned(
              right: -20,
              bottom: -20,
              child: Opacity(
                opacity: 0.2,
                child: Icon(
                  icon,
                  size: 140,
                  color: Colors.white,
                ),
              ),
            ),

            // 2. Content Padding
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Label
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white, // Gold/Tan brand color
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Value
                  Text(
                    value,
                    style: TextStyle(
                      color: Colors.white, // Deep emerald green
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCards() {
    final cardWidth = MediaQuery.of(context).size.width * 0.85;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(), // Provides a premium "bounce" feel
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(width: cardWidth, child: _statCard("Active Leads", "24", Icons.people),),
          const SizedBox(width: 16),
          SizedBox(width: cardWidth, child: _statCard("Total Properties", "12", Icons.home),),
          const SizedBox(width: 16),
          SizedBox(width: cardWidth, child: _statCard("Wallet Balance", "\$1,200", Icons.account_balance_wallet),),
          const SizedBox(width: 16),
      ],
      ),
      
    );
  }

  Widget _cta() {
    return Row(
      children: [
        Expanded(
            child: SizedBox(
              height: 56, // Standard height for production buttons
              child: ElevatedButton(
                onPressed: () {
                  debugPrint("Find Property Pressed");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06220E), // Very dark green from image
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Find Property",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12), // Spacing between buttons

          // 2. Add Property Button (White with Icon)
          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  debugPrint("Add Property Pressed");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF235F23), // Lighter brand green
                  elevation: 2,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline, 
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Add Property",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _leadsListView() {
    final leadProvider = context.watch<LeadProvider>();

    if (leadProvider.isLoading && leadProvider.leads.isEmpty) {
    return const Center(child: CircularProgressIndicator(color: Color(0xFF235F23),));
  }

    if (leadProvider.leads.isEmpty) {
      return const Center(child: Text("No active leads found. Start adding some!"));
    }

    return Scrollbar(
      thumbVisibility: true,
      child: ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: min(leadProvider.leads.length, 5),
      itemBuilder: (context, index) {
        final lead = leadProvider.leads[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFF235F23),
            child: Text(lead.name[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
          ),
          title: Text(lead.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(lead.budget.toString()),
          trailing: Text(lead.status, style: TextStyle(
            color: lead.status == "New Lead" ? Colors.orange : Colors.green,
            fontWeight: FontWeight.w600,
          )),
        );
      },
    )
    );
  }
}

