import 'package:flutter/material.dart';

import '../../models/transactions/transaction_model.dart';
import '../../repositories/history/history_repository.dart';

class HistoryViewModel extends ChangeNotifier {
  final HistoryRepository repository;

  HistoryViewModel({required this.repository});

  DateTime? startDate;
  DateTime? endDate;
  double total = 0;
  List<TransactionModel> items = [];
  bool loading = true;

  Future<void> load() async {
    loading = true;
    notifyListeners();

    items = await repository.loadAllTransactions();
    if (items.isNotEmpty) {
      items.sort((a, b) => a.id.compareTo(b.id));
      startDate = _dateFromId(items.first.id);
      endDate = _dateFromId(items.last.id);
      total = items.fold(0.0, (sum, t) => sum + t.amount);
    }

    loading = false;
    notifyListeners();
  }

  DateTime _dateFromId(int id) {
    return DateTime.fromMillisecondsSinceEpoch(id);
  }
}
