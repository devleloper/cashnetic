import 'package:auto_route/auto_route.dart';
import 'package:cashnetic/models/transactions/transaction_model.dart';
import 'package:cashnetic/ui/features/transaction_add/view/transaction_add_screen.dart';
import 'package:cashnetic/ui/features/transaction_edit/view/transaction_edit_screen.dart';
import 'package:cashnetic/utils/format_currency.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../view_models/shared/transactions_view_model.dart';

@RoutePage()
class IncomesScreen extends StatelessWidget {
  const IncomesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TransactionsViewModel>();

    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final end = DateTime(today.year, today.month, today.day, 23, 59, 59);

    var todayIncomes = vm.incomes
        .where((t) => t.dateTime.isAfter(start) && t.dateTime.isBefore(end))
        .toList();

    // Удаляем дубликаты по ID
    final unique = <int>{};
    todayIncomes = todayIncomes.where((t) => unique.add(t.id)).toList();

    // Сортируем по дате — новые сверху
    todayIncomes.sort((a, b) => b.dateTime.compareTo(a.dateTime));

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
            child: todayIncomes.isEmpty
                ? const Center(child: Text('Нет доходов за сегодня'))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: todayIncomes.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final t = todayIncomes[index];
                      return ListTile(
                        title: Text(t.categoryTitle),
                        subtitle: t.comment?.isNotEmpty == true
                            ? Text(
                                t.comment!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                        trailing: Text(
                          '${formatCurrency(t.amount)} ₽',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  TransactionEditScreen(transaction: t),
                            ),
                          );
                          context
                              .read<TransactionsViewModel>()
                              .loadTransactions();
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
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const TransactionAddScreen(type: TransactionType.income),
            ),
          );
          context.read<TransactionsViewModel>().loadTransactions();
        },
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
    );
  }
}
