import 'package:cashnetic/repositories/transactions/transactions_repository.dart';
import 'package:flutter/material.dart';

import '../../models/transactions/transaction_model.dart';

class ExpensesViewModel extends ChangeNotifier {
  final TransactionsRepository repository;

  ExpensesViewModel({required this.repository});

  List<TransactionModel> transactions = [];
  double total = 0;
  bool loading = true;

  Future<void> load() async {
    loading = true;
    notifyListeners();

    final loaded = await repository.loadTransactions();
    transactions = List<TransactionModel>.from(loaded);
    total = transactions.fold(0.0, (sum, t) => sum + t.amount);

    loading = false;
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel t) async {
    await repository.addTransaction(t);
    transactions.insert(0, t);
    total += t.amount;
    notifyListeners();
  }

  Future<void> deleteTransaction(int id) async {
    await repository.deleteTransaction(id);
    transactions.removeWhere((t) => t.id == id);
    total = transactions.fold(0.0, (sum, t) => sum + t.amount);
    notifyListeners();
  }

  Future<void> updateTransaction(TransactionModel t) async {
    await repository.updateTransaction(t);
    final idx = transactions.indexWhere((x) => x.id == t.id);
    if (idx >= 0) transactions[idx] = t;
    total = transactions.fold(0.0, (sum, x) => sum + x.amount);
    notifyListeners();
  }
}
