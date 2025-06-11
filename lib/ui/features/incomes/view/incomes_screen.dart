import 'package:auto_route/auto_route.dart';
import 'package:cashnetic/models/transactions/transaction_model.dart';
import 'package:cashnetic/utils/format_currency.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../view_models/shared/transactions_view_model.dart';
import '../../../ui.dart';

@RoutePage()
class IncomesScreen extends StatelessWidget {
  const IncomesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TransactionsViewModel>();
    final todayIncomes = vm.transactions
        .where(
          (t) =>
              t.dateTime.day == DateTime.now().day &&
              t.dateTime.month == DateTime.now().month &&
              t.dateTime.year == DateTime.now().year &&
              t.amount > 0,
        )
        .toList();

    final total = todayIncomes.fold<double>(0, (sum, t) => sum + t.amount);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green,
        elevation: 0,
        title: const Text(
          'Доходы сегодня',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<TransactionsViewModel>().loadTransactions();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFFD9F3DB),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Всего',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  '${formatCurrency(total)} ₽',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: todayIncomes.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final t = todayIncomes[index];
                return ListTile(
                  title: Text(t.categoryTitle),
                  trailing: Text(
                    '${formatCurrency(t.amount)} ₽',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TransactionEditScreen(transaction: t),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'income_fab',
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const TransactionAddScreen(type: TransactionType.income),
            ),
          );
        },
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
    );
  }
}
