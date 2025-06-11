import 'package:auto_route/annotations.dart';
import 'package:cashnetic/models/transactions/transaction_model.dart';
import 'package:cashnetic/utils/category_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../ui.dart';

@RoutePage()
class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ExpensesViewModel>();

    // Сортировка по дате (новые в начале)
    final sorted = [...vm.transactions]
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

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
                  child: sorted.isEmpty
                      ? const Center(child: Text('Нет расходов за сегодня'))
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: sorted.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, index) {
                            final e = sorted[index];
                            final bgColor = colorFor(
                              e.categoryTitle,
                            ).withOpacity(0.2);
                            return MyItemListTile(e: e, bgColor: bgColor);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: MyFloatingActionButton(
        icon: Icons.add,
        onPressesd: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const TransactionAddScreen(type: TransactionType.expense),
            ),
          );

          // Обязательно обновляем список после возвращения
          await context.read<ExpensesViewModel>().load();
        },
      ),
    );
  }
}
