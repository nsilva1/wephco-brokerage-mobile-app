import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/leads_provider.dart';
import '../providers/user_provider.dart';
import '../providers/property_provider.dart';
import '../utils/helper_functions.dart';
import '../models/user.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We watch the providers to ensure the dashboard updates automatically
    final leadProvider = context.watch<LeadProvider>();
    final leads = leadProvider.leads;
    final isLoading = leadProvider.isLoading;
    final userProvider = context.watch<UserProvider>();
    final currentUser = userProvider.currentUser;
    final propertyProvider = context.watch<PropertyProvider>();
    final properties = propertyProvider.properties;
    final double totalValue = properties.fold(0, (sum, property) => sum + property.price);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB), // Clean surface background
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Welcome Header
              _buildHeader(context, currentUser!),

              const SizedBox(height: 30),

              // 2. Metrics Bento Grid
              _buildMetricsGrid(context, leads.length, currentUser.commission, totalValue),

              const SizedBox(height: 24),

              // 3. Property Action Buttons (From your previous file)
              _propertyActionButtons(context),

              const SizedBox(height: 32),

              // 4. Recent Leads Section
              _buildSectionHeader(
                context, 
                title: "Priority Leads", 
                onViewAll: () {
                  Navigator.pushNamed(context, '/leads');
                }
              ),
              
              if (isLoading && leads.isEmpty)
                const Center(child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(color: Color(0xFF235F23)),
                ))
              else if (leads.isEmpty)
                _buildEmptyLeads()
              else
                _buildRecentLeadsList(context, leads),

              const SizedBox(height: 100), // Space for bottom nav padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserInfo user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Good Morning,",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              Text(
                user.name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF003527),
                ),
              ),
            ],
          ),
          // const CircleAvatar(
          //   radius: 28,
          //   backgroundColor: Colors.grey,
          //   child: Icon(Icons.person),
          // ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context, int totalLeads, double commissions, double totalValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Row 1: Large Listing Value Card
          _buildListingValueCard(totalValue),
          
          const SizedBox(height: 16),

          // Row 2: Secondary Metrics
          Row(
            children: [
              Expanded(
                child: _buildSmallMetricCard(
                  label: "ACTIVE LEADS",
                  value: totalLeads.toString(),
                  icon: Icons.group_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSmallMetricCard(
                  label: "COMMISSIONS",
                  value: "₦$commissions",
                  icon: Icons.payments_outlined,
                  isHighlight: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListingValueCard(double totalValue) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Opacity(
                opacity: 0.05,
                child: Icon(Icons.account_balance, size: 140, color: Colors.grey.shade900),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "TOTAL LISTING VALUE",
                    style: TextStyle(color: Color(0xFF775A19), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatCurrency(totalValue, compact: true),
                    style: TextStyle(color: Color(0xFF003527), fontSize: 38, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallMetricCard({required String label, required String value, required IconData icon, bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isHighlight ? const Color(0xFF003527) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: isHighlight ? Colors.amber : const Color(0xFF775A19), size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: isHighlight ? Colors.white : const Color(0xFF003527),
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: isHighlight ? Colors.white70 : Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required String title, required VoidCallback onViewAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF003527)),
          ),
          TextButton(
            onPressed: onViewAll,
            child: const Text("View All", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF235F23))),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentLeadsList(BuildContext context, List leads) {
    // Only show the top 4 leads for the dashboard preview
    final previewLeads = leads.take(4).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: previewLeads.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final lead = previewLeads[index];
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFF0F2F5),
                child: Text(lead.name[0], style: const TextStyle(color: Color(0xFF003527), fontWeight: FontWeight.bold)),
              ),
              title: Text(lead.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(formatCurrency(lead.budget, compact: true, currency: lead.currency), style: const TextStyle(color: Color(0xFF775A19), fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                Navigator.pushNamed(context, '/leads');
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyLeads() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.0),
        child: Text("No leads yet. Use 'Add Lead' to start!"),
      ),
    );
  }

  Widget _propertyActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // 1. Find Property Button (Dark Emerald Green)
          Expanded(
            child: SizedBox(
              height: 58, // Increased height for a more premium feel
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/properties');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06220E), // Brand dark emerald
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: Colors.black.withValues(alpha: 0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Find Property",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12), // Spacing between buttons

          // 2. Add Property Button (Modern White/Outlined)
          Expanded(
            child: SizedBox(
              height: 58,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/properties/new');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF003527), // Deep green text
                  elevation: 0,
                  side: BorderSide(
                    color: Colors.grey.withValues(alpha: 0.2), 
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.add_circle_outline_rounded, 
                      size: 22,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Add Property",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}