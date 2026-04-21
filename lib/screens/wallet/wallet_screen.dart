import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wephco_brokerage/models/transaction.dart';
import '../../providers/user_provider.dart';
import '../../utils/helper_functions.dart';
// import '../../data/mock_data.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            _buildBalanceCard(context),
            const SizedBox(height: 30),
            _buildQuickActions(context),
            const SizedBox(height: 30),
            _buildTransactionHeader(context),
            _buildTransactionList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final currentUser = userProvider.currentUser;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF003527), // Deep Emerald
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF003527).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Stack(
        children: [
          // Background Decoration
          Positioned(
            right: -30,
            top: -30,
            child: Icon(
              Icons.account_balance_wallet_rounded,
              size: 180,
              color: Colors.white.withValues(alpha: 0.03),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "WALLET BALANCE",
                      style: TextStyle(
                        color: Color(0xFFFED488), // Gold
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "NGN",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  formatCurrency(currentUser?.wallet.availableBalance ?? 0, compact: true, currency: 'NGN'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(color: Colors.white24),
                const SizedBox(height: 16),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     _cardSubStat("PENDING", currentUser?.wallet.escrowBalance.toString() ?? '0'),
                //     _cardSubStat("NEXT PAYOUT", "OCT 12"),
                //   ],
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _actionItems(context)
    );
  }

  Widget _actionItems(BuildContext context) {
  return Padding(
    padding: EdgeInsetsGeometry.all(8),
    child: Row(
      spacing: 15.0,
      children: [
        Expanded(
    child: SizedBox(
    height: 50,
    child: ElevatedButton.icon(
    onPressed: (){},
    icon: Icon(Icons.south_west_rounded, color: Colors.white, size: 22),
    label: Text(
      "Withdraw",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        letterSpacing: 0.3,
        color: Colors.white
      ),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: const Color(0xFF404944), // TextVariant color
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
    ),
  ),
  ),
  ),

  Expanded(
    child: SizedBox(
    height: 50,
    child: ElevatedButton.icon(
    onPressed: () {},
    icon: Icon(Icons.sync_alt_rounded, color: Theme.of(context).colorScheme.primary, size: 22),
    label: Text(
      'Transfer',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        letterSpacing: 0.3,
        color: Theme.of(context).colorScheme.primary
      ),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF404944), // TextVariant color
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
    ),
  ),
  ),
  )
      ],
    ),
  );
}

  Widget _buildTransactionHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Transactions",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF003527)),
          ),
          TextButton(
            onPressed: () { Navigator.pushNamed(context, '/wallet/transactions'); },
            child: const Text("See Transaction History", style: TextStyle(color: Color(0xFF235F23), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(BuildContext context) {
    // final transactions = MockData.fakeTransactions.take(4).toList();

    final userProvider = context.watch<UserProvider>();
    final currentUser = userProvider.currentUser;

    final List<Transaction>? transactions = currentUser?.transactions.take(4).toList();

    if(transactions!.isEmpty){
      return Center(
        child: Text('No Recorded Transactions'),
      );
    } else {
      return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final bool isCredit = tx.transactionType == 'Credit';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (isCredit ? Colors.green : Colors.red).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCredit ? Icons.add_chart_rounded : Icons.outbox_rounded,
                  color: isCredit ? Colors.green.shade800 : Colors.red.shade800,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.description,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      formatSmartDate(tx.createdAt),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                "${isCredit ? '+' : '-'}${formatCurrency(tx.amount, currency: 'NGN')}",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: isCredit ? Colors.green.shade800 : Colors.red.shade800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        );
      },
    );
    }
  }
}