// analysis_repository.dart
import 'package:dartz/dartz.dart';
import 'package:cashnetic/domain/entities/transaction.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'package:cashnetic/presentation/features/analysis/bloc/analysis_state.dart';
import 'package:cashnetic/presentation/features/analysis/bloc/analysis_event.dart';
import 'package:cashnetic/presentation/features/transactions/repositories/transactions_repository.dart';
import 'package:cashnetic/presentation/features/categories/repositories/categories_repository.dart';
import 'package:flutter/material.dart';

abstract interface class AnalysisRepository {
  Future<List<int>> getAllAvailableYears(AnalysisType type);
  Future<AnalysisResult> getAnalysisForYear(int year, AnalysisType type);
  Future<AnalysisResult> getAnalysisForYears(
    List<int> years,
    AnalysisType type,
  );
  Future<AnalysisResult> getAnalysisForPeriod(
    DateTime from,
    DateTime to,
    AnalysisType type,
  );
}

class AnalysisRepositoryImpl implements AnalysisRepository {
  final TransactionsRepository transactionRepository;
  final CategoriesRepository categoryRepository;
  final List<Color> sectionColors;

  AnalysisRepositoryImpl({
    required this.transactionRepository,
    required this.categoryRepository,
    required this.sectionColors,
  });

  @override
  Future<List<int>> getAllAvailableYears(AnalysisType type) async {
    final (txs, _) = await transactionRepository.getTransactions(
      from: DateTime(2000, 1, 1),
      to: DateTime(2100, 12, 31, 23, 59, 59),
    );
    final cats = await categoryRepository.getCategories();
    final filtered = txs.where((t) {
      final cat = cats.isNotEmpty
          ? cats.firstWhere(
              (c) => c.id == t.categoryId,
              orElse: () => cats.first,
            )
          : Category(
              id: 0,
              name: '—',
              emoji: '❓',
              isIncome: false,
              color: '#E0E0E0',
            );
      return type == AnalysisType.expense ? !cat.isIncome : cat.isIncome;
    }).toList();
    final years = filtered.map((t) => t.timestamp.year).toSet().toList()
      ..sort();
    return years;
  }

  @override
  Future<AnalysisResult> getAnalysisForYear(int year, AnalysisType type) async {
    final start = DateTime(year, 1, 1);
    final end = DateTime(year, 12, 31, 23, 59, 59);
    final allYears = await getAllAvailableYears(type);
    final (txs, _) = await transactionRepository.getTransactions(
      from: start,
      to: end,
    );
    final cats = await categoryRepository.getCategories();
    final filtered = txs.where((t) {
      final cat = cats.isNotEmpty
          ? cats.firstWhere(
              (c) => c.id == t.categoryId,
              orElse: () => cats.first,
            )
          : Category(
              id: 0,
              name: '—',
              emoji: '❓',
              isIncome: false,
              color: '#E0E0E0',
            );
      return type == AnalysisType.expense ? !cat.isIncome : cat.isIncome;
    }).toList();
    if (filtered.isEmpty) {
      return AnalysisResult(
        data: [],
        total: 0,
        periodStart: start,
        periodEnd: end,
      );
    }
    final Map<int, List<Transaction>> byCategory = {};
    for (final t in filtered) {
      byCategory.putIfAbsent(t.categoryId ?? 0, () => []).add(t);
    }
    final total = filtered.fold<double>(0, (sum, t) => sum + t.amount);
    final data = <CategoryChartData>[];
    int colorIdx = 0;
    byCategory.forEach((catId, txs) {
      final cat = cats.isNotEmpty
          ? cats.firstWhere((c) => c.id == catId, orElse: () => cats.first)
          : Category(
              id: 0,
              name: 'Other',
              emoji: '',
              isIncome: false,
              color: '#E0E0E0',
            );
      final amount = txs.fold<double>(0, (sum, t) => sum + t.amount);
      final percent = total > 0 ? (amount / total) * 100 : 0;
      final lastDate = txs.isNotEmpty
          ? txs.map((t) => t.timestamp).reduce((a, b) => a.isAfter(b) ? a : b)
          : null;
      data.add(
        CategoryChartData(
          id: cat.id,
          categoryTitle: cat.name,
          categoryIcon: cat.emoji,
          amount: amount,
          percent: percent.toDouble(),
          color: sectionColors[colorIdx % sectionColors.length],
          lastTransactionDate: lastDate,
        ),
      );
      colorIdx++;
    });
    return AnalysisResult(
      data: data,
      total: total,
      periodStart: start,
      periodEnd: end,
    );
  }

  @override
  Future<AnalysisResult> getAnalysisForYears(
    List<int> years,
    AnalysisType type,
  ) async {
    if (years.isEmpty) {
      return AnalysisResult(
        data: [],
        total: 0,
        periodStart: DateTime.now(),
        periodEnd: DateTime.now(),
      );
    }
    final allYears = await getAllAvailableYears(type);
    final cats = await categoryRepository.getCategories();
    final allTxs = <Transaction>[];
    for (final year in years) {
      final start = DateTime(year, 1, 1);
      final end = DateTime(year, 12, 31, 23, 59, 59);
      final (txs, _) = await transactionRepository.getTransactions(
        from: start,
        to: end,
      );
      allTxs.addAll(txs);
    }
    final filtered = allTxs.where((t) {
      final cat = cats.isNotEmpty
          ? cats.firstWhere(
              (c) => c.id == t.categoryId,
              orElse: () => cats.first,
            )
          : Category(
              id: 0,
              name: '—',
              emoji: '❓',
              isIncome: false,
              color: '#E0E0E0',
            );
      return type == AnalysisType.expense ? !cat.isIncome : cat.isIncome;
    }).toList();
    if (filtered.isEmpty) {
      return AnalysisResult(
        data: [],
        total: 0,
        periodStart: DateTime(years.first, 1, 1),
        periodEnd: DateTime(years.last, 12, 31, 23, 59, 59),
      );
    }
    final Map<int, List<Transaction>> byCategory = {};
    for (final t in filtered) {
      byCategory.putIfAbsent(t.categoryId ?? 0, () => []).add(t);
    }
    final total = filtered.fold<double>(0, (sum, t) => sum + t.amount);
    final data = <CategoryChartData>[];
    int colorIdx = 0;
    byCategory.forEach((catId, txs) {
      final cat = cats.isNotEmpty
          ? cats.firstWhere((c) => c.id == catId, orElse: () => cats.first)
          : Category(
              id: 0,
              name: 'Other',
              emoji: '',
              isIncome: false,
              color: '#E0E0E0',
            );
      final amount = txs.fold<double>(0, (sum, t) => sum + t.amount);
      final percent = total > 0 ? (amount / total) * 100 : 0;
      final lastDate = txs.isNotEmpty
          ? txs.map((t) => t.timestamp).reduce((a, b) => a.isAfter(b) ? a : b)
          : null;
      data.add(
        CategoryChartData(
          id: cat.id,
          categoryTitle: cat.name,
          categoryIcon: cat.emoji,
          amount: amount,
          percent: percent.toDouble(),
          color: sectionColors[colorIdx % sectionColors.length],
          lastTransactionDate: lastDate,
        ),
      );
      colorIdx++;
    });
    return AnalysisResult(
      data: data,
      total: total,
      periodStart: DateTime(years.first, 1, 1),
      periodEnd: DateTime(years.last, 12, 31, 23, 59, 59),
    );
  }

  @override
  Future<AnalysisResult> getAnalysisForPeriod(
    DateTime from,
    DateTime to,
    AnalysisType type,
  ) async {
    final (txs, _) = await transactionRepository.getTransactions(
      from: from,
      to: to,
    );
    final cats = await categoryRepository.getCategories();
    final filtered = txs.where((t) {
      final cat = cats.isNotEmpty
          ? cats.firstWhere(
              (c) => c.id == t.categoryId,
              orElse: () => cats.first,
            )
          : Category(
              id: 0,
              name: '—',
              emoji: '❓',
              isIncome: false,
              color: '#E0E0E0',
            );
      return type == AnalysisType.expense ? !cat.isIncome : cat.isIncome;
    }).toList();
    if (filtered.isEmpty) {
      return AnalysisResult(
        data: [],
        total: 0,
        periodStart: from,
        periodEnd: to,
      );
    }
    final Map<int, List<Transaction>> byCategory = {};
    for (final t in filtered) {
      byCategory.putIfAbsent(t.categoryId ?? 0, () => []).add(t);
    }
    final total = filtered.fold<double>(0, (sum, t) => sum + t.amount);
    final data = <CategoryChartData>[];
    int colorIdx = 0;
    byCategory.forEach((catId, txs) {
      final cat = cats.isNotEmpty
          ? cats.firstWhere((c) => c.id == catId, orElse: () => cats.first)
          : Category(
              id: 0,
              name: 'Other',
              emoji: '',
              isIncome: false,
              color: '#E0E0E0',
            );
      final amount = txs.fold<double>(0, (sum, t) => sum + t.amount);
      final percent = total > 0 ? (amount / total) * 100 : 0;
      final lastDate = txs.isNotEmpty
          ? txs.map((t) => t.timestamp).reduce((a, b) => a.isAfter(b) ? a : b)
          : null;
      data.add(
        CategoryChartData(
          id: cat.id,
          categoryTitle: cat.name,
          categoryIcon: cat.emoji,
          amount: amount,
          percent: percent.toDouble(),
          color: sectionColors[colorIdx % sectionColors.length],
          lastTransactionDate: lastDate,
        ),
      );
      colorIdx++;
    });
    return AnalysisResult(
      data: data,
      total: total,
      periodStart: from,
      periodEnd: to,
    );
  }
}
