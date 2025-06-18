import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashnetic/domain/repositories/transaction_repository.dart';
import 'package:cashnetic/domain/repositories/category_repository.dart';
import 'package:cashnetic/domain/entities/transaction.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'package:flutter/material.dart';
import 'analysis_event.dart';
import 'analysis_state.dart';

class AnalysisBloc extends Bloc<AnalysisEvent, AnalysisState> {
  final TransactionRepository transactionRepository;
  final CategoryRepository categoryRepository;
  final List<Color> sectionColors = const [
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.red,
    Colors.purple,
    Colors.teal,
    Color(0xFFFDD835),
    Color(0xFF8D6E63),
    Color(0xFF64B5F6),
  ];

  AnalysisBloc({
    required this.transactionRepository,
    required this.categoryRepository,
  }) : super(AnalysisLoading()) {
    on<LoadAnalysis>(_onLoadAnalysis);
    on<ChangeYear>(_onChangeYear);
  }

  Future<void> _onLoadAnalysis(
    LoadAnalysis event,
    Emitter<AnalysisState> emit,
  ) async {
    emit(AnalysisLoading());
    final start = DateTime(event.year, 1, 1);
    final end = DateTime(event.year, 12, 31, 23, 59, 59);
    // Получаем все транзакции за год
    final txResult = await transactionRepository.getTransactionsByPeriod(
      1,
      start,
      end,
    ); // accountId=1 (TODO: поддержка мультиаккаунтов)
    final catResult = await categoryRepository.getAllCategories();
    final txs = txResult.fold((_) => <Transaction>[], (txs) => txs);
    final cats = catResult.fold((_) => <Category>[], (cats) => cats);
    // Фильтруем по типу
    final filtered = txs.where((t) {
      final cat = cats.firstWhere(
        (c) => c.id == t.categoryId,
        orElse: () => Category(id: 0, name: '', emoji: '', isIncome: false),
      );
      return event.type == AnalysisType.expense ? !cat.isIncome : cat.isIncome;
    }).toList();
    if (filtered.isEmpty) {
      emit(
        AnalysisLoaded(
          result: AnalysisResult(
            data: [],
            total: 0,
            periodStart: start,
            periodEnd: end,
          ),
          selectedYear: event.year,
          availableYears: [event.year],
        ),
      );
      return;
    }
    // Группируем по категориям
    final Map<int, List<Transaction>> byCategory = {};
    for (final t in filtered) {
      byCategory.putIfAbsent(t.categoryId ?? 0, () => []).add(t);
    }
    final total = filtered.fold<double>(0, (sum, t) => sum + t.amount);
    final data = <CategoryChartData>[];
    int colorIdx = 0;
    byCategory.forEach((catId, txs) {
      final cat = cats.firstWhere(
        (c) => c.id == catId,
        orElse: () =>
            Category(id: 0, name: 'Другое', emoji: '', isIncome: false),
      );
      final amount = txs.fold<double>(0, (sum, t) => sum + t.amount);
      final percent = total > 0 ? (amount / total) * 100 : 0;
      data.add(
        CategoryChartData(
          categoryTitle: cat.name,
          categoryIcon: cat.emoji,
          amount: amount,
          percent: percent.toDouble(),
          color: sectionColors[colorIdx % sectionColors.length],
        ),
      );
      colorIdx++;
    });
    // Определяем доступные года
    final years = filtered.map((t) => t.timestamp.year).toSet().toList()
      ..sort();
    emit(
      AnalysisLoaded(
        result: AnalysisResult(
          data: data,
          total: total,
          periodStart: start,
          periodEnd: end,
        ),
        selectedYear: event.year,
        availableYears: years.isEmpty ? [event.year] : years,
      ),
    );
  }

  Future<void> _onChangeYear(
    ChangeYear event,
    Emitter<AnalysisState> emit,
  ) async {
    add(LoadAnalysis(year: event.year, type: event.type));
  }
}
