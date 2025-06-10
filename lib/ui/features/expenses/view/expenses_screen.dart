import 'package:cashnetic/ui/features/history/view/history_screen.dart';
import 'package:cashnetic/ui/features/transaction_add/view/transaction_add_screen.dart';
import 'package:cashnetic/ui/features/transaction_edit/view/transaction_edit_screen.dart';
import 'package:cashnetic/ui/widgets/floating_action_button.dart';
import 'package:cashnetic/utils/category_utils.dart';
import 'package:cashnetic/view_models/expenses/expenses_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ExpensesViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Расходы сегодня'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  color: Colors.green.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Всего',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${vm.total.toStringAsFixed(0)} ₽',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: vm.transactions.isEmpty
                      ? const Center(child: Text('Нет расходов за сегодня'))
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: vm.transactions.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, index) {
                            final e = vm.transactions[index];
                            final bgColor = colorFor(
                              e.categoryTitle,
                            ).withOpacity(0.3);
                            return ListTile(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        TransactionEditScreen(transaction: e),
                                  ),
                                );
                              },
                              leading: CircleAvatar(
                                backgroundColor: bgColor,
                                child: Text(
                                  e.categoryIcon,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                              title: Text(e.categoryTitle),
                              subtitle: e.comment != null
                                  ? Text(e.comment!)
                                  : null,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${e.amount.toStringAsFixed(0)} ₽',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: MyFloatingActionButton(
        icon: Icons.add,
        onPressesd: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TransactionAddScreen()),
          );
        },
      ),
    );
  }
}
