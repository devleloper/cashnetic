import 'package:cashnetic/models/transactions/transaction_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../models/analysis_result/analysis_result_model.dart';
import '../../repositories/analysis/analysis_repository.dart';
import '../../utils/analysis_compute.dart';
import '../shared/transactions_view_model.dart'; // для TransactionType

class AnalysisViewModel extends ChangeNotifier {
  final AnalysisRepository repo;
  AnalysisResult? result;
  bool loading = false;

  int selectedYear = DateTime.now().year;
  List<int> availableYears = [];
  List<Color> sectionColors = const [
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

  AnalysisViewModel({required this.repo}) {
    // можно вызывать load только при передаче типа
  }

  Future<void> load(TransactionType type) async {
    loading = true;
    notifyListeners();

    final txnsRaw = await repo.fetchTransactions(
      from: DateTime(selectedYear, 1, 1),
      to: DateTime(selectedYear, 12, 31, 23, 59, 59),
    );

    final txns = txnsRaw.where((t) => t.type == type).toList();

    if (txns.isEmpty) {
      result = null;
      availableYears = [selectedYear];
    } else {
      result = await compute(
        computeAnalysisIsolate,
        AnalysisInput(
          transactions: txns,
          colorValues: sectionColors.map((c) => c.value).toList(),
        ),
      );

      final startYear = txns
          .map((e) => DateTime.fromMillisecondsSinceEpoch(e.id).year)
          .reduce((a, b) => a < b ? a : b);
      final endYear = txns
          .map((e) => DateTime.fromMillisecondsSinceEpoch(e.id).year)
          .reduce((a, b) => a > b ? a : b);

      availableYears = [for (var y = startYear; y <= endYear; y++) y];
      if (!availableYears.contains(selectedYear)) {
        selectedYear = availableYears.last;
        await load(type);
      }
    }

    loading = false;
    notifyListeners();
  }

  void changeYear(int year, TransactionType type) {
    if (year != selectedYear) {
      selectedYear = year;
      load(type);
    }
  }

  // Геттеры для UI
  double get total => result?.total ?? 0;

  String get startLabel => result != null
      ? '${_monthName(result!.periodStart.month)} ${result!.periodStart.year}'
      : '';

  String get endLabel => result != null
      ? '${_monthName(result!.periodEnd.month)} ${result!.periodEnd.year}'
      : '';

  List<CategoryChartData> get categories => result?.data ?? [];

  String _monthName(int m) {
    const names = [
      'январь',
      'февраль',
      'март',
      'апрель',
      'май',
      'июнь',
      'июль',
      'август',
      'сентябрь',
      'октябрь',
      'ноябрь',
      'декабрь',
    ];
    return names[m - 1];
  }
}
