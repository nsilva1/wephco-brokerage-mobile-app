import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wephco_brokerage/providers/leads_provider.dart';
import 'package:wephco_brokerage/providers/property_provider.dart';
import 'package:wephco_brokerage/screens/properties/property_details.dart';
import '../../utils/helper_functions.dart';

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  @override
  Widget build(BuildContext context) {
    // final colorScheme = Theme.of(context).colorScheme;
    // Color primaryColor = colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Brighter,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar / Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: _header(),
              ),
            ),
            
            // Search Section - Sticky-like placement
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              sliver: SliverToBoxAdapter(child: _searchInput()),
            ),

            // Leads List
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: _leadsListSliver(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    final leads = context.watch<LeadProvider>().filteredLeads;
    return Row(
      children: [
        Expanded(
          child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "My Pipeline",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1A1C1E),
              ),
        ),
        Text(
          "You have ${leads.length} active lead",
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      ],
    ),
        ),
        FloatingActionButton.extended(
            onPressed: () => Navigator.pushNamed(context, '/leads/new'),
            label: const Text("New Lead"),
            icon: const Icon(Icons.add),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
        
      ],
    );
  }

  Widget _searchInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TextField(
        onChanged: (value) => context.read<LeadProvider>().updateSearch(value),
        decoration: InputDecoration(
          hintText: "Search name, email, or budget...",
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.blueGrey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _leadsListSliver() {
    final leads = context.watch<LeadProvider>().filteredLeads;
    final propertyProvider = context.read<PropertyProvider>();

    if (leads.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_search_rounded, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text("No leads match your search", style: TextStyle(color: Colors.grey[500])),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final lead = leads[index];
          final property = lead.propertyId != null 
              ? propertyProvider.getPropertyById(lead.propertyId!) 
              : null;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  // Top section: Lead Identity
                  ListTile(
                    onTap: () => Navigator.pushNamed(context, '/leads/detail', arguments: lead),
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      child: Text(
                        lead.name?.substring(0, 1).toUpperCase() ?? '?',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                    title: Text(
                      lead.name ?? 'Unknown Lead',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    subtitle: Text(lead.email ?? 'No email provided'),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  ),

                  
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('INTERESTED IN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: Colors.blueGrey)),
                              const SizedBox(height: 4),
                              Text(
                                property?.title ?? 'General Inquiry',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('BUDGET', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.blueGrey)),
                            const SizedBox(height: 4),
                            Text(
                              formatCurrency(lead.budget as double, currency: lead.currency ?? ''),
                              style: TextStyle(fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.primary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Bottom Action Bar
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        _actionButton(
                          icon: Icons.mail_outline_rounded,
                          onTap: () => sendEmail(toEmail: lead.email ?? '', subject: 'Interest in ${property?.title}', body: 'Hello ${lead.name}'),
                        ),
                        const SizedBox(width: 8),
                        _actionButton(
                          icon: Icons.phone_in_talk_outlined,
                          onTap: () => callPhone(lead.phone ?? ''),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: property != null 
                            ? () => Navigator.push(context, MaterialPageRoute(builder: (context) => PropertyDetails(propertyId: property.id!))) 
                            : null,
                          child: property != null 
                            ? const Text("View Property", style: TextStyle(fontWeight: FontWeight.bold)) 
                            : const Text("No Linked Property", style: TextStyle(color: Colors.grey)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        childCount: leads.length,
      ),
    );
  }

  Widget _actionButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: Colors.blueGrey[700]),
      ),
    );
  }
}