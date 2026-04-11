import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/lead.dart';
// import '../../models/property.dart';
import '../../providers/leads_provider.dart';
import '../../providers/property_provider.dart';
import '../../providers/user_provider.dart';

class AddLeadScreen extends StatefulWidget {
  const AddLeadScreen({super.key});

  @override
  State<AddLeadScreen> createState() => _AddLeadScreenState();
}

class _AddLeadScreenState extends State<AddLeadScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _budgetController = TextEditingController();
  final _sourceController = TextEditingController(text: 'Social Media'); // Default

  // State
  String _selectedCurrency = 'NGN';
  String? _selectedPropertyId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _budgetController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPropertyId == null) {
      _showErrorSnackBar("Please select a property of interest.");
      return;
    }

    final user = context.read<UserProvider>().currentUser;
    if (user == null) return;

    setState(() => _isSubmitting = true);

    final newLead = Lead(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      userId: user.id,
      propertyId: _selectedPropertyId!,
      budget: double.tryParse(_budgetController.text) ?? 0.0,
      source: _sourceController.text.trim(),
      status: 'New Lead',
      createdAt: DateTime.now(),
      currency: _selectedCurrency,
    );

    final success = await context.read<LeadProvider>().addLead(newLead);

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      _showSuccessSnackBar("Lead successfully added to your pipeline!");
      Navigator.pop(context); // Return to previous screen
    } else if (mounted) {
      _showErrorSnackBar("Failed to save lead. Please try again.");
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF003527),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final properties = context.watch<PropertyProvider>().properties;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("New Prospect", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF003527),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Capture Lead Details",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF003527)),
              ),
              const SizedBox(height: 8),
              const Text("Fill in the information below to start tracking this prospect.", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),

              _buildTextField(
                label: "Full Name",
                controller: _nameController,
                icon: Icons.person_outline,
                validator: (v) => v!.isEmpty ? "Enter prospect name" : null,
              ),
              const SizedBox(height: 20),

              _buildTextField(
                label: "Email Address",
                controller: _emailController,
                icon: Icons.alternate_email,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => !v!.contains('@') ? "Enter a valid email" : null,
              ),
              const SizedBox(height: 20),

              _buildTextField(
                label: "Phone Number",
                controller: _phoneController,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? "Enter phone number" : null,
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      label: "Budget Amount",
                      controller: _budgetController,
                      icon: Icons.payments_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: _buildDropdown<String>(
                      label: "Currency",
                      value: _selectedCurrency,
                      items: ['NGN', 'USD'],
                      onChanged: (v) => setState(() => _selectedCurrency = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildDropdown<String>(
                label: "Property of Interest",
                value: _selectedPropertyId,
                hint: "Select a listing...",
                items: properties.where((p) => p.id != null).map((p) => p.id!).toList(),
                itemLabel: (id) => properties.firstWhere((p) => p.id == id).title,
                onChanged: (v) => setState(() => _selectedPropertyId = v),
              ),
              const SizedBox(height: 20),

              _buildTextField(
                label: "Lead Source (e.g. WhatsApp, Referral)",
                controller: _sourceController,
                icon: Icons.share_outlined,
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003527),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Save Prospect", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF235F23)),
            filled: true,
            fillColor: const Color(0xFFF7F9FB),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required void Function(T?) onChanged,
    String? Function(T)? itemLabel,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F9FB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              hint: hint != null ? Text(hint) : null,
              items: items.map((T item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(itemLabel != null ? itemLabel(item)! : item.toString()),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}