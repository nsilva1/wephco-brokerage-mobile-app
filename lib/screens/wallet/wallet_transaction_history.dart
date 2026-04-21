import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wephco_brokerage/models/transaction.dart';
import '../../providers/user_provider.dart';
import '../../utils/helper_functions.dart';
// import '../../data/mock_data.dart';

class WalletTransactionHistory extends StatefulWidget {
  const WalletTransactionHistory({super.key});

  @override
  State<WalletTransactionHistory> createState() => _WalletTransactionHistoryState();
}

class _WalletTransactionHistoryState extends State<WalletTransactionHistory> {


  @override
  Widget build(BuildContext context) {
    // final transactions = MockData.fakeTransactions;

    final userProvider = context.watch<UserProvider>();
    final currentUser = userProvider.currentUser;

    final List<Transaction>? transactions = currentUser?.transactions;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Transaction History", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            _transactionsListView(transactions)
          ],
        ),
      ),
    );
  }

  Widget _transactionsListView(List<Transaction>? transactions) {
    if(transactions!.isEmpty){
      return Center(
        child: Text('No Recorded Transactions'),
      );
    } else {
      return ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: transactions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final tx = transactions[index];
          final bool isCredit = tx.transactionType == 'Credit';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            // borderRadius: BorderRadius.circular(20),
            // border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
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
                "${isCredit ? '+' : ''}${formatCurrency(tx.amount, currency: 'NGN')}",
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