import '../models/analysis_result/analysis_result_model.dart';
import '../models/transactions/transaction_model.dart';
import 'package:flutter/material.dart';

AnalysisResult computeAnalysis(List<TransactionModel> transactions) {
  final periodStart = transactions
      .map((e) => DateTime.fromMillisecondsSinceEpoch(e.id))
      .reduce((a, b) => a.isBefore(b) ? a : b);
  final periodEnd = transactions
      .map((e) => DateTime.fromMillisecondsSinceEpoch(e.id))
      .reduce((a, b) => a.isAfter(b) ? a : b);
  final total = transactions.fold<double>(0, (sum, e) => sum + e.amount);

  final sums = <String, double>{};
  final icons = <String, String>{};
  for (var e in transactions) {
    sums[e.categoryTitle] = (sums[e.categoryTitle] ?? 0) + e.amount;
    icons[e.categoryTitle] = e.categoryIcon;
  }

  final colors = [
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.red,
    Colors.purple,
    Colors.teal,
    Colors.yellow.shade700,
  ];

  int idx = 0;
  final data = sums.entries.map((entry) {
    final percent = (entry.value / total) * 100;
    final color = colors[idx % colors.length];
    idx++;

    return CategoryChartData(
      categoryTitle: entry.key,
      categoryIcon: icons[entry.key] ?? '',
      amount: entry.value,
      percent: percent,
      color: color,
    );
  }).toList();

  return AnalysisResult(
    data: data,
    total: total,
    periodStart: periodStart,
    periodEnd: periodEnd,
  );
}
