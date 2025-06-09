import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../ui.dart';

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
            onPressed: () {},
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
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFFE8F5E9),
                                child: Text(
                                  e.categoryIcon,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                              title: Text(e.categoryTitle),
                              subtitle: e.comment != null
                                  ? Text(e.comment!)
                                  : null,
                              trailing: Text(
                                '${e.amount.toStringAsFixed(0)} ₽',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onTap: () {},
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
