import 'package:flutter/material.dart';

import '../../../../data/data.dart';
import '../../../../models/models.dart';

class ExpensesViewModel extends ChangeNotifier {
  final TransactionsRepository repository;

  ExpensesViewModel({required this.repository});

  List<TransactionModel> transactions = [];
  double total = 0;
  bool loading = true;

  Future<void> load() async {
    loading = true;
    notifyListeners();

    transactions = await repository.fetchTodayTransactions();
    total = await repository.fetchTodayTotal();

    loading = false;
    notifyListeners();
  }
}
