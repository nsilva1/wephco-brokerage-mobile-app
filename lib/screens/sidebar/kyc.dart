import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wephco_brokerage/providers/user_provider.dart';
import '../../utils/bottom_sheet.dart';
import 'package:flutter/services.dart';
import '../../services/flutterwave_service.dart';
import '../../models/bank.dart';

part 'kyc_widgets.dart';

class KYCScreen extends StatefulWidget {
  const KYCScreen({super.key});

  @override
  State<KYCScreen> createState() => _KYCScreenState();
}

class _KYCScreenState extends State<KYCScreen> {
  bool _verifyNIN = false;
  bool _verifyBVN = false;

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Verification & Banking",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Card 1: ID Verification
            _buildIDCard(
              context,
              nin: user?.bankInfo?.nin,
              bvn: user?.bankInfo?.bvn,
            ),
            const SizedBox(height: 20),
            // Card 2: Banking Information
            _buildBankingCard(
              context,
              bankName: user?.bankInfo?.bankName,
              accountNo: user?.bankInfo?.bankAccountNumber.toString(),
              accountName: user?.bankInfo?.bankAccountName,
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildIDCard(BuildContext context, {int? nin, int? bvn}) {
  bool ninVerified = nin != null;
  bool bvnVerified = bvn != 0;

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: _cardDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.badge_outlined, color: Theme.of(context).primaryColor),
            const SizedBox(width: 10),
            const Text(
              "ID Verification",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const Divider(height: 30),

        // — Buttons row (only show buttons for unverified IDs) —
        if (!ninVerified || !bvnVerified)
          Row(
            children: [
              if (!ninVerified)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() {
                      _verifyNIN = !_verifyNIN;
                      _verifyBVN = false; // collapse the other
                    }),
                    icon: const Icon(Icons.badge_outlined, size: 16),
                    label: const Text("Verify NIN"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _verifyNIN ? Theme.of(context).colorScheme.primary : Colors.blueGrey,
                      side: BorderSide(
                        color: _verifyNIN ? Theme.of(context).colorScheme.primary : Colors.blueGrey,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              if (!ninVerified && !bvnVerified) const SizedBox(width: 12),
              if (!bvnVerified)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() {
                      _verifyBVN = !_verifyBVN;
                      _verifyNIN = false; // collapse the other
                    }),
                    icon: const Icon(Icons.fingerprint, size: 16),
                    label: const Text("Verify BVN"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _verifyBVN ? Theme.of(context).colorScheme.primary : Colors.blueGrey,
                      side: BorderSide(
                        color: _verifyBVN ? Theme.of(context).colorScheme.primary : Colors.blueGrey,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
            ],
          ),

        // — Verified status rows —
        if (ninVerified) ...[
          const SizedBox(height: 12),
          _verificationRow("NIN (National ID)", nin.toString()),
        ],
        if (bvnVerified) ...[
          const SizedBox(height: 12),
          _verificationRow("BVN (Bank Verification Number)", bvn.toString()),
        ],

        // — Conditional form fields —
        if (_verifyNIN) ...[
          const SizedBox(height: 16),
          _ninFormField(context),
        ],
        if (_verifyBVN) ...[
          const SizedBox(height: 16),
          _bvnFormField(context),
        ],
      ],
    ),
  );
}

  Widget _buildBankingCard(BuildContext context,
      {String? bankName, String? accountNo, String? accountName}) {
    bool hasData = bankName != null && accountNo != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_outlined,
                  color: Theme.of(context).primaryColor),
              const SizedBox(width: 10),
              const Text(
                "Banking Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 30),
          if (hasData) ...[
            _infoRow("Bank Name", bankName),
            _infoRow("Account Number", accountNo),
            _infoRow("Account Name", accountName ?? ''),
          ] else
            Center(
              child: Column(
                children: [
                  Text(
                    "No banking information found.",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => _showAddBankSheet(context),
                    child: const Text("Add Bank Account"),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _verificationRow(String label, String? value) {
    bool isVerified = value != null && value.isNotEmpty;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
              color: Colors.blueGrey, fontWeight: FontWeight.w500),
        ),
        if (isVerified)
          Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.green, size: 20),
              SizedBox(width: 4),
              Text(
                "Verified",
                style:
                    TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ],
          )
        else
          GestureDetector(
            onTap: () {
              if(label.contains("BVN")) {
                setState(() => _verifyBVN = true);
              } else if(label.contains("NIN")) {
                // setState(() => _verifyNIN = true);
              }
            },
            child: const Text(
              "Tap to Verify",
              style: TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      border: Border.all(color: const Color(0xFFE2E8F0)),
    );
  }

  void _showAddBankSheet(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      child: const BankDetailsForm(),
    );
  }

  Widget _ninFormField(BuildContext context) {
  final ninNotifier = ValueNotifier<String>('');

  return ValueListenableBuilder<String>(
    valueListenable: ninNotifier,
    builder: (context, ninValue, _) {
      return Column(
        children: [
          TextFormField(
            initialValue: '',
            decoration: const InputDecoration(
              labelText: "Enter NIN",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            onChanged: (value) {
              ninNotifier.value = value;
            },
          ),
          if (ninValue.length == 11) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _submitNIN(ninValue);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary, // Brand dark emerald
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: Colors.black.withValues(alpha: 0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              child: const Text("Verify NIN"),
            ),
          ],
        ],
      );
    },
  );
}

  Widget _bvnFormField(BuildContext context) {
    final bvnNotifier = ValueNotifier<String>('');

  return ValueListenableBuilder<String>(
    valueListenable: bvnNotifier,
    builder: (context, bvnValue, _) {
      return Column(
        children: [
          TextFormField(
            initialValue: '',
            decoration: const InputDecoration(
              labelText: "Enter BVN",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            onChanged: (value) {
              bvnNotifier.value = value;
            },
          ),
          if (bvnValue.length == 11) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _submitBVN(bvnValue);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary, // Brand dark emerald
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: Colors.black.withValues(alpha: 0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              child: const Text("Verify BVN"),
            ),
          ],
        ],
      );
    },
  );
  }


  void _submitNIN(String nin) async { 
    final error = await context.read<UserProvider>().submitNIN(nin);

  if (!mounted) return;

  if (error != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error), backgroundColor: Colors.red),
    );
  } else {
    setState(() => _verifyNIN = false); // collapse the form
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("NIN added successfully."), backgroundColor: Colors.green),
    );
  }
   }

  void _submitBVN(String bvn) async { 
    final error = await context.read<UserProvider>().submitBVN(bvn);

  if (!mounted) return;

  if (error != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error), backgroundColor: Colors.red),
    );
  } else {
    setState(() => _verifyBVN = false); // collapse the form
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("BVN added successfully."), backgroundColor: Colors.green),
    );
  }
   }
}