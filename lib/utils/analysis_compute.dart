import 'package:flutter/material.dart';
import 'package:cashnetic/domain/entities/transaction.dart';
import 'package:cashnetic/presentation/features/analysis/bloc/analysis_state.dart';

/// Входная модель для изолята
class AnalysisInput {
  final List<Transaction> transactions;
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
      .map((e) => e.timestamp)
      .reduce((a, b) => a.isBefore(b) ? a : b);

  final periodEnd = transactions
      .map((e) => e.timestamp)
      .reduce((a, b) => a.isAfter(b) ? a : b);

  final total = transactions.fold<double>(0, (sum, e) => sum + e.amount);

  final Map<int, num> sums = {}; // categoryId -> сумма
  final Map<int, String> titles = {}; // categoryId -> title
  final Map<int, String> icons = {}; // categoryId -> emoji

  for (var e in transactions) {
    final catId = e.categoryId ?? 0;
    sums[catId] = ((sums[catId] ?? 0.0) + e.amount.toDouble());
    titles[catId] = '';
    icons[catId] = '';
  }

  final entries = sums.entries
      .map((e) => MapEntry(e.key, double.tryParse(e.value.toString()) ?? 0.0))
      .toList();
  int idx = 0;
  final data = entries.map((entry) {
    final percent = (total == 0) ? 0 : (entry.value / total) * 100;
    final color = Color(colorValues[idx % colorValues.length]);
    idx++;

    return CategoryChartData(
      categoryTitle: titles[entry.key] ?? '',
      categoryIcon: icons[entry.key] ?? '',
      amount: entry.value.toDouble(),
      percent: percent.toDouble(),
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
