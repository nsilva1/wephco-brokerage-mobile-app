import 'package:flutter/material.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  static const List<Map<String, String>> _faqs = [
    {
      'category': 'Wallet & Withdrawals',
      'question': 'How do I withdraw my commission?',
      'answer':
          'Go to the Wallet tab and tap "Withdraw". Enter the amount you wish to withdraw and submit. Withdrawal requests are reviewed by the admin and processed within 1-3 business days.',
    },
    {
      'category': 'Wallet & Withdrawals',
      'question': 'Why is my balance showing in escrow?',
      'answer':
          'When you submit a withdrawal request, the amount is moved to escrow while it is being reviewed. Once approved it is deducted from escrow. If rejected, it is returned to your available balance.',
    },
    {
      'category': 'Wallet & Withdrawals',
      'question': 'How long does a withdrawal take?',
      'answer':
          'Withdrawals are typically processed within 1-3 business days after approval. You will receive a notification when your withdrawal has been approved or rejected.',
    },
    {
      'category': 'KYC & Verification',
      'question': 'Why do I need to verify my BVN?',
      'answer':
          'BVN verification is required by Nigerian financial regulations to confirm your identity before any payouts can be made to your bank account.',
    },
    {
      'category': 'KYC & Verification',
      'question': 'My account name could not be resolved. What do I do?',
      'answer':
          'Ensure you have selected the correct bank and entered a valid 10-digit NUBAN account number. If the issue persists, contact support.',
    },
    {
      'category': 'Leads',
      'question': 'How do I add a new lead?',
      'answer':
          'Go to the Leads tab and tap the "+" button. Fill in the client details, assign a property if applicable, and save.',
    },
    {
      'category': 'Leads',
      'question': 'What do the lead statuses mean?',
      'answer':
          'New: just created. Contacted: you have reached out. Viewing: property viewing scheduled. Negotiating: in price discussion. Closed: deal completed. Lost: lead did not convert.',
    },
    {
      'category': 'Commission',
      'question': 'How is my commission calculated?',
      'answer':
          'Commission is calculated by the admin when a deal is closed and credited directly to your wallet. You can see your total commission on the Profile screen.',
    },
    {
      'category': 'Account',
      'question': 'How do I change my password?',
      'answer':
          'Go to Settings and tap "Change Password". You will need to enter your current password before setting a new one.',
    },
    {
      'category': 'Account',
      'question': 'How do I enable biometric login?',
      'answer':
          'After logging in with your password, you will be prompted to enable biometric login. You can also toggle it in Settings under the Account section.',
    },
  ];

  List<Map<String, String>> get _filtered {
    if (_searchQuery.isEmpty) return _faqs;
    final q = _searchQuery.toLowerCase();
    return _faqs.where((faq) {
      return faq['question']!.toLowerCase().contains(q) ||
          faq['answer']!.toLowerCase().contains(q) ||
          faq['category']!.toLowerCase().contains(q);
    }).toList();
  }

  Map<String, List<Map<String, String>>> get _grouped {
    final Map<String, List<Map<String, String>>> groups = {};
    for (final faq in _filtered) {
      final cat = faq['category']!;
      groups.putIfAbsent(cat, () => []).add(faq);
    }
    return groups;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "FAQ",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextFormField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: "Search questions...",
                hintStyle:
                    TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon:
                    const Icon(Icons.search, color: Colors.blueGrey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.blueGrey),
                        onPressed: () => setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        }),
                      )
                    : null,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.grey[200]!, width: 1.5),
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
          ),

          // FAQ list
          Expanded(
            child: grouped.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text(
                          "No results for \"$_searchQuery\"",
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: grouped.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 4, bottom: 8, top: 8),
                            child: Text(
                              entry.key.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.blueGrey,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: const Color(0xFFE2E8F0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: entry.value
                                  .asMap()
                                  .entries
                                  .map((e) => Column(
                                        children: [
                                          _FAQTile(faq: e.value),
                                          if (e.key < entry.value.length - 1)
                                            const Divider(
                                              height: 1,
                                              indent: 16,
                                              endIndent: 16,
                                              color: Color(0xFFF1F5F9),
                                            ),
                                        ],
                                      ))
                                  .toList(),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FAQTile extends StatefulWidget {
  final Map<String, String> faq;
  const _FAQTile({required this.faq});

  @override
  State<_FAQTile> createState() => _FAQTileState();
}

class _FAQTileState extends State<_FAQTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.faq['question']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF1A1C1E),
                      ),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.blueGrey,
                    size: 20,
                  ),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 10),
                Text(
                  widget.faq['answer']!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.blueGrey,
                    height: 1.6,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}