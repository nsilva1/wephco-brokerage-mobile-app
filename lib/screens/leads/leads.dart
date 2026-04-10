import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wephco_brokerage/providers/leads_provider.dart';
import 'package:wephco_brokerage/providers/property_provider.dart';
import '../../utils/helper_functions.dart';

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  @override
  Widget build(BuildContext context) {
    // final leads = context.watch<LeadProvider>().filteredLeads;
    

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 50),
              _searchInput(),
              const SizedBox(height: 30,),
              _leadsListView(),
            ],
          ),
        ),
      ),
    );
  }


  Widget _header() {
      final leads = context.watch<LeadProvider>().filteredLeads;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("My Leads (${leads.length})", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            // Handle add lead action
          },
          icon: const Icon(Icons.add),
          label: const Text("Add Lead"),
        ),
      ],
    );
  }


  Widget _searchInput() {
    return TextField(
      onChanged: (value) => context.read<LeadProvider>().updateSearch(value),
      decoration: InputDecoration(
        hintText: "Search by name or email...",
        prefixIcon: const Icon(Icons.search, color: Color(0xFF235F23),),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }


  Widget _leadsListView() {
    final leads = context.watch<LeadProvider>().filteredLeads;
    final propertyProvider = context.read<PropertyProvider>();

    if (leads.isEmpty) {
      return const Center(child: Text("No leads found. Try adjusting your search or add new leads."));
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: leads.length,
      separatorBuilder: (_, __) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final lead = leads[index];
        final property = propertyProvider.getPropertyById(lead.propertyId);
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lead.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                      const SizedBox(height: 4),
                      Text(lead.email, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  // Text(lead.status, style: TextStyle(
                  //   color: lead.status == "New Lead" ? Colors.orange : Colors.green,
                  //   fontWeight: FontWeight.w600,
                  // )),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
                child: Padding(
                  padding: EdgeInsetsGeometry.all(10),
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('INTEREST', style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${property?.title}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(formatCurrency(lead.budget as double, currency: lead.currency), style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))
                  ],
                ),
                )
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                
                children: [
                  Row(
                    spacing: 10,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
                child: GestureDetector(
                  onTap: () {
                    sendEmail(toEmail: lead.email, subject: 'Interest in ${property?.title}', body: 'Hello ${lead.name}');
                  },
                  child: Icon(Icons.mail),
                ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
                child: GestureDetector(
                  onTap: () {
                    callPhone(lead.phone);
                  },
                  child: Icon(Icons.phone),
                ),
                      ),
                    ],
                  ),
                  TextButton(onPressed: (){}, child: Text('View Property'))
                ],
              )
            ],
          )
        );
      },
    );
  }
}