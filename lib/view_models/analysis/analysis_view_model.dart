import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../models/analysis_result/analysis_result_model.dart';
import '../../repositories/analysis/analysis_repository.dart';
import '../../utils/analysis_compute.dart';

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
    Color(0xFFFDD835), // ярко‑жёлтый
    Color(0xFF8D6E63), // коричневый
    Color(0xFF64B5F6), // светло‑голубой
  ];

  AnalysisViewModel({required this.repo}) {
    load();
  }

  Future<void> load() async {
    loading = true;
    notifyListeners();

    final txns = await repo.fetchTransactions(
      from: DateTime(selectedYear, 1, 1),
      to: DateTime(selectedYear, 12, 31, 23, 59, 59),
    );

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
        await load();
      }
    }

    loading = false;
    notifyListeners();
  }

  void changeYear(int year) {
    if (year != selectedYear) {
      selectedYear = year;
      load();
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
