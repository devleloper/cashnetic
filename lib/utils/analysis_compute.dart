import 'package:flutter/material.dart';
import '../models/analysis_result/analysis_result_model.dart';
import '../models/transactions/transaction_model.dart';

/// Входная модель для изолята
class AnalysisInput {
  final List<TransactionModel> transactions;
  final List<int> colorValues;

  const AnalysisInput({required this.transactions, required this.colorValues});
}

/// Изолируемая функция анализа
AnalysisResult computeAnalysisIsolate(AnalysisInput input) {
  final transactions = input.transactions;
  final colorValues = input.colorValues;

  if (transactions.isEmpty) {
    final now = DateTime.now();
    return AnalysisResult(data: [], total: 0, periodStart: now, periodEnd: now);
  }

  final periodStart = transactions
      .map((e) => DateTime.fromMillisecondsSinceEpoch(e.id))
      .reduce((a, b) => a.isBefore(b) ? a : b);

  final periodEnd = transactions
      .map((e) => DateTime.fromMillisecondsSinceEpoch(e.id))
      .reduce((a, b) => a.isAfter(b) ? a : b);

  final total = transactions.fold<double>(0, (sum, e) => sum + e.amount);

  final Map<String, double> sums = {};
  final Map<String, String> icons = {};

  for (var e in transactions) {
    sums[e.categoryTitle] = (sums[e.categoryTitle] ?? 0) + e.amount;
    icons[e.categoryTitle] = e.categoryIcon;
  }

  int idx = 0;
  final data = sums.entries.map((entry) {
    final percent = (entry.value / total) * 100;
    final color = Color(colorValues[idx % colorValues.length]);
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
