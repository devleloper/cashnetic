import 'package:flutter/material.dart';
import '../../repositories/transactions/transactions_repository.dart';
import '../../models/transactions/transaction_model.dart';

class IncomesViewModel extends ChangeNotifier {
  final TransactionsRepository repository;

  IncomesViewModel({required this.repository});

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
              t.type == TransactionType.income &&
              t.dateTime.isAfter(todayStart) &&
              t.dateTime.isBefore(todayEnd),
        )
        .toList();

    total = transactions.fold(0.0, (sum, t) => sum + t.amount);

    loading = false;
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel t) async {
    await repository.addTransaction(t);
    if (t.type == TransactionType.income) {
      transactions.insert(0, t);
      total += t.amount;
      notifyListeners();
    }
  }

  Future<void> updateTransaction(TransactionModel t) async {
    await repository.updateTransaction(t);
    final index = transactions.indexWhere((x) => x.id == t.id);
    if (index >= 0) {
      transactions[index] = t;
    }
    total = transactions.fold(0.0, (sum, t) => sum + t.amount);
    notifyListeners();
  }

  Future<void> deleteTransaction(int id) async {
    await repository.deleteTransaction(id);
    transactions.removeWhere((t) => t.id == id);
    total = transactions.fold(0.0, (sum, t) => sum + t.amount);
    notifyListeners();
  }
}
