import 'package:cashnetic/models/transactions/transaction_model.dart';
import 'package:cashnetic/ui/features/analysis/view/analysis_screen.dart';
import 'package:cashnetic/ui/widgets/item_list_tile.dart';
import 'package:cashnetic/utils/category_utils.dart';
import 'package:cashnetic/view_models/analysis/analysis_view_model.dart';
import 'package:cashnetic/view_models/shared/transactions_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ExpensesHistoryScreen extends StatelessWidget {
  const ExpensesHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TransactionsViewModel>();

    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));

    // Filter only expenses within last 30 days:
    final all = vm.expenses
        .where((t) => t.dateTime.isAfter(monthAgo) && t.dateTime.isBefore(now))
        .toList();

    // Sort descending by date
    all.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    final start = all.isNotEmpty
        ? DateFormat('dd.MM.yyyy').format(
            all.last.dateTime, // oldest
          )
        : '—';

    final end = all.isNotEmpty
        ? DateFormat('dd.MM.yyyy').format(
            all.first.dateTime, // newest
          )
        : '—';

    final total = all.fold<double>(0, (sum, t) => sum + t.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Расходы за месяц'),
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
            child: all.isEmpty
                ? const Center(child: Text('Нет расходов за последний месяц'))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: all.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final e = all[index];
                      final bgColor = colorFor(
                        e.categoryTitle,
                      ).withOpacity(0.2);
                      return MyItemListTile(e: e, bgColor: bgColor);
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
