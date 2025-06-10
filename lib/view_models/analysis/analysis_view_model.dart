import 'package:flutter/foundation.dart';
import '../../models/analysis_result/analysis_result_model.dart';
import '../../repositories/analysis/analysis_repository.dart';
import '../../utils/analysis_compute.dart';

class AnalysisViewModel extends ChangeNotifier {
  final AnalysisRepository repo;
  AnalysisResult? result;
  bool loading = false;

  AnalysisViewModel({required this.repo});

  Future<void> load() async {
    loading = true;
    notifyListeners();

    final txns = await repo.fetchTransactions(
      from: DateTime(2020),
      to: DateTime.now(),
    );
    result = await compute(computeAnalysis, txns);

    loading = false;
    notifyListeners();
  }

  // упрощённые геттеры для UI
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
