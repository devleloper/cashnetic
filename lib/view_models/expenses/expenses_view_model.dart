import 'package:flutter/material.dart';
import 'package:cashnetic/repositories/transactions/transactions_repository.dart';
import 'package:cashnetic/models/transactions/transaction_model.dart';

class ExpensesViewModel extends ChangeNotifier {
  final TransactionsRepository repository;

  ExpensesViewModel({required this.repository});

  List<TransactionModel> transactions = [];
  double total = 0;
  bool loading = true;

  Future<void> load() async {
    loading = true;
    notifyListeners();

    final all = await repository.loadTransactions();

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    transactions = all
        .where(
          (t) =>
              t.dateTime.isAfter(todayStart) && t.dateTime.isBefore(todayEnd),
        )
        .toList();

    total = transactions.fold(0.0, (sum, t) => sum + t.amount);

    loading = false;
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel t) async {
    await repository.addTransaction(t);
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    if (t.dateTime.isAfter(todayStart) && t.dateTime.isBefore(todayEnd)) {
      transactions.insert(0, t);
      total += t.amount;
      notifyListeners();
    }
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
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    if (idx >= 0) {
      if (t.dateTime.isAfter(todayStart) && t.dateTime.isBefore(todayEnd)) {
        transactions[idx] = t;
      } else {
        transactions.removeAt(idx);
      }
    } else {
      if (t.dateTime.isAfter(todayStart) && t.dateTime.isBefore(todayEnd)) {
        transactions.insert(0, t);
      }
    }

    total = transactions.fold(0.0, (sum, t) => sum + t.amount);
    notifyListeners();
  }
}
