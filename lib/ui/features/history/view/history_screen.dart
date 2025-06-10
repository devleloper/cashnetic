import 'package:cashnetic/ui/features/analysis/view/analysis_screen.dart';
import 'package:cashnetic/utils/category_utils.dart';
import 'package:cashnetic/view_models/analysis/analysis_view_model.dart';
import 'package:cashnetic/view_models/expenses/expenses_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../transaction_edit/transaction_edit.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ExpensesViewModel>();
    final transactions = vm.transactions;

    final start = transactions.isNotEmpty
        ? DateFormat('dd.MM.yyyy').format(
            DateTime.fromMillisecondsSinceEpoch(
              transactions.reduce((a, b) => a.id < b.id ? a : b).id,
            ),
          )
        : '—';

    final end = transactions.isNotEmpty
        ? DateFormat('dd.MM.yyyy').format(
            DateTime.fromMillisecondsSinceEpoch(
              transactions.reduce((a, b) => a.id > b.id ? a : b).id,
            ),
          )
        : '—';

    final total = transactions.fold<double>(0, (sum, t) => sum + t.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Моя история'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.white),
            onPressed: () async {
              await context.read<AnalysisViewModel>().load();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AnalysisScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFFD9F3DB),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                _HistoryPeriodRow(label: 'Начало', value: start),
                _HistoryPeriodRow(label: 'Конец', value: end),
                _HistoryPeriodRow(
                  label: 'Сумма',
                  value: '${total.toStringAsFixed(0)} ₽',
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: transactions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final e = transactions[index];
                final time = DateFormat(
                  'HH:mm',
                ).format(DateTime.fromMillisecondsSinceEpoch(e.id));
                return ListTile(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TransactionEditScreen(transaction: e),
                      ),
                    );
                  },

                  leading: CircleAvatar(
                    backgroundColor: colorFor(
                      e.categoryTitle,
                      vm.sectionColors,
                    ).withOpacity(0.3),

                    child: Text(e.categoryIcon),
                  ),
                  title: Text(e.categoryTitle),
                  subtitle: e.comment != null ? Text(e.comment!) : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${e.amount.toStringAsFixed(0)} ₽',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            time,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryPeriodRow extends StatelessWidget {
  final String label, value;

  const _HistoryPeriodRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
