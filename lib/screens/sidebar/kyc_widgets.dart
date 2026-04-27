part of 'kyc.dart';


class BankDetailsForm extends StatefulWidget {
  const BankDetailsForm({super.key});

  @override
  State<BankDetailsForm> createState() => _BankDetailsFormState();
}

class _BankDetailsFormState extends State<BankDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final _accountNoController = TextEditingController();
  final _accountNameController = TextEditingController();
  bool _isSaving = false;
  final FlutterwaveService _flutterwaveService = FlutterwaveService();
  List<Bank> _banks = [];
  bool _isLoadingBanks = false;
  Bank? _selectedBank;

  @override
void initState() {
  super.initState();
  _loadBanks();
}

Future<void> _loadBanks() async {
  setState(() => _isLoadingBanks = true);
  try {
    final banks = await _flutterwaveService.getBanks();
    setState(() => _banks = banks);
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  } finally {
    setState(() => _isLoadingBanks = false);
  }
}

  @override
  void dispose() {
    _accountNoController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom:40),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with subtle handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Text(
              "Settlement Account",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1C1E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Ensure the account name matches your identity verification document.",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 32),

            // Bank Selection
            _isLoadingBanks
  ? const Center(child: CircularProgressIndicator())
  : DropdownButtonFormField<Bank>(
      value: _selectedBank,
      items: _banks.map((bank) {
        return DropdownMenuItem(value: bank, alignment: AlignmentGeometry.centerLeft, child: Text(bank.name, style: TextStyle(fontSize: 12),),);
      }).toList(),
      onChanged: (val) => {
        setState(() {
          _selectedBank = val;
        })
      },
      decoration: _inputDecoration("Select Bank", Icons.account_balance_rounded),
      validator: (v) => v == null ? "Please select a bank" : null,
    ),
  
            const SizedBox(height: 20),

            // Account Number
            TextFormField(
              controller: _accountNoController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: _inputDecoration("Account Number", Icons.numbers_rounded),
              style: const TextStyle(letterSpacing: 2, fontWeight: FontWeight.w500),
              validator: (v) => v!.length != 10 ? "Enter a valid 10-digit NUBAN" : null,
            ),
            const SizedBox(height: 20),

            // Account Name
            TextFormField(
              controller: _accountNameController,
              keyboardType: TextInputType.text,
              inputFormatters: [
                LengthLimitingTextInputFormatter(100),
              ],
              textCapitalization: TextCapitalization.characters,
              decoration: _inputDecoration("Account Name", Icons.person_outline_rounded),
              validator: (v) => v!.isEmpty ? "Enter the account name" : null,
            ),
            const SizedBox(height: 32),

            // Submit Button
            SliverButton(
              onPressed: _isSaving ? null : _showConfirmDialog,
              isLoading: _isSaving,
              label: "Save Bank Details",
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 18),
      labelStyle: const TextStyle(fontSize: 14, color: Colors.blueGrey),
      floatingLabelStyle: TextStyle(color: Theme.of(context).primaryColor),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
    );
  }

//   Future<void> _getAccountName() async {
//   if (_formKey.currentState!.validate()) {
//     if (_selectedBank == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please select a bank first.")),
//       );
//       return;
//     }

//     setState(() => _isSaving = true);
//     try {
//       final accountName = await _flutterwaveService.resolveAccountName(
//         _accountNoController.text,
//         _selectedBank!.code,
//       );

//       if (!mounted) return;

//       setState(() {
//         _accountNameController.text = accountName;
//         nameVerified = accountName.isNotEmpty;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(accountName.isNotEmpty ? "Account name resolved." : "Could not resolve account. Check your details."),
//           backgroundColor: accountName.isNotEmpty ? Colors.green : Colors.red,
//         ),
//       );
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Failed to resolve account name."), backgroundColor: Colors.red),
//       );
//     } finally {
//       if (mounted) setState(() => _isSaving = false);
//     }
//   }
// }

  Future<void> _confirmBankDetails() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      
      String? response = await context.read<UserProvider>().submitBankInfo(
        bankName: _selectedBank!.name,
        bankCode: _selectedBank!.code,
        accountNumber: _accountNoController.text,
        accountName: _accountNameController.text,
      );
      
      if (mounted) {
        setState(() => _isSaving = false);
        if (response != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Bank details saved successfully!")),
          );
          Navigator.of(context).pop();
        }
      }
    }
  }

  Future<void> _showConfirmDialog() async {
  if (!_formKey.currentState!.validate()) return;
  if (_selectedBank == null) return;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        "Confirm Bank Details",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Please confirm the details below are correct before saving.",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 20),
          _confirmRow("Bank", _selectedBank!.name),
          _confirmRow("Account Number", _accountNoController.text),
          _confirmRow("Account Name", _accountNameController.text),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Cancel", style: TextStyle(color: Colors.blueGrey)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text("Confirm"),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    await _confirmBankDetails();
  }
}

Widget _confirmRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(color: Colors.blueGrey, fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
      ],
    ),
  );
}
}

// Custom button component for reuse
class SliverButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;

  const SliverButton({super.key, this.onPressed, required this.label, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: isLoading 
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}