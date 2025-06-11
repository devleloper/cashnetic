import 'package:cashnetic/models/transactions/transaction_model.dart';
import 'package:cashnetic/ui/features/analysis/view/analysis_screen.dart';
import 'package:cashnetic/ui/widgets/item_list_tile.dart';
import 'package:cashnetic/utils/category_utils.dart';
import 'package:cashnetic/view_models/analysis/analysis_view_model.dart';
import 'package:cashnetic/view_models/expenses/expenses_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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
                final bgColor = colorFor(e.categoryTitle).withOpacity(0.2);
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
