import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wephco_brokerage/utils/helper_functions.dart';
import '../../models/lead.dart';
import '../../providers/leads_provider.dart';

class LeadDetailScreen extends StatefulWidget {
  final Lead lead;
  const LeadDetailScreen({super.key, required this.lead});

  @override
  State<LeadDetailScreen> createState() => _LeadDetailScreenState();
}

class _LeadDetailScreenState extends State<LeadDetailScreen> {
  late Lead _lead;
  final _noteController = TextEditingController();
  bool _isSaving = false;

  // Match these to your Lead model's status values
  static const List<String> _statuses = [
    'New',
    'Contacted',
    'Viewing',
    'Negotiating',
    'Closed',
    'Lost',
  ];

  static const Map<String, Color> _statusColors = {
    'New': Colors.blueGrey,
    'Contacted': Colors.blue,
    'Viewing': Colors.orange,
    'Negotiating': Colors.purple,
    'Closed': Colors.green,
    'Lost': Colors.red,
  };

  @override
  void initState() {
    super.initState();
    _lead = widget.lead;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isSaving = true);
    final error = await context
        .read<LeadProvider>()
        .updateLeadStatus(_lead.id!, newStatus);

    if (!mounted) return;
    setState(() {
      _isSaving = false;
      if (error == null) _lead = _lead.copyWith(status: newStatus);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? "Status updated to $newStatus"),
        backgroundColor: error != null ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _addNote() async {
    final note = _noteController.text.trim();
    if (note.isEmpty) return;

    setState(() => _isSaving = true);
    final error = await context
        .read<LeadProvider>()
        .addNoteToLead(_lead.id!, note);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (error == null) {
      _noteController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Note added."),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColors[_lead.status] ?? Colors.blueGrey;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Lead Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // — Client Info Card —
            _sectionCard(
              context,
              title: "Client Information",
              icon: Icons.person_outline,
              children: [
                _infoRow("Full Name", _lead.name!),
                _divider(),
                _infoRow("Phone", _lead.phone!),
                _divider(),
                _infoRow("Email", _lead.email!),
                _divider(),
                _infoRow("Source", _lead.source ?? '—'),
                _divider(),
                _infoRow("Created", formatSmartDate(_lead.createdAt)),
              ],
            ),
            const SizedBox(height: 16),

            // — Property Interest Card —
            _sectionCard(
              context,
              title: "Property Interest",
              icon: Icons.home_outlined,
              children: [
                _infoRow("Property", _lead.propertyId ?? 'Not assigned'),
                _divider(),
                _infoRow("Budget", formatCurrency(_lead.budget!, compact: false)),
              ],
            ),
            const SizedBox(height: 16),

            // — Status Card —
            _sectionCard(
              context,
              title: "Status",
              icon: Icons.flag_outlined,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        _lead.status!,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _showStatusPicker(context),
                      child: const Text("Change Status"),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // — Notes Card —
            _sectionCard(
              context,
              title: "Notes",
              icon: Icons.notes_outlined,
              children: [
                if (_lead.notes != null && _lead.notes!.isNotEmpty)
                  Text(
                    _lead.notes!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1A1C1E),
                      height: 1.5,
                    ),
                  )
                else
                  Text(
                    "No notes yet.",
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Add a note...",
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey[200]!,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _addNote,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text("Save Note"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showStatusPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Update Status",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            ..._statuses.map(
              (status) => ListTile(
                leading: CircleAvatar(
                  radius: 8,
                  backgroundColor: _statusColors[status] ?? Colors.blueGrey,
                ),
                title: Text(status),
                trailing: _lead.status == status
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  if (_lead.status != status) _updateStatus(status);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.blueGrey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      const Divider(height: 1, color: Color(0xFFF1F5F9));
}