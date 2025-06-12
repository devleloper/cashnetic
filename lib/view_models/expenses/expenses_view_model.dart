import 'package:flutter/material.dart';
import 'package:cashnetic/repositories/transactions/transactions_repository.dart';
import 'package:cashnetic/models/transactions/transaction_model.dart';

class ExpensesViewModel extends ChangeNotifier {
  final TransactionsRepository repository;

  ExpensesViewModel({required this.repository});

  List<Color> sectionColors = const [
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.red,
    Colors.purple,
    Colors.teal,
    Color(0xFFFDD835), // жёлтый
    Color(0xFF8D6E63), // коричневый
    Color(0xFF64B5F6), // голубой
  ];

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

    transactions = all.where((t) {
      final isToday =
          t.dateTime.isAfter(todayStart) && t.dateTime.isBefore(todayEnd);
      return isToday && t.type == TransactionType.expense;
    }).toList();

    transactions.sort((a, b) => b.dateTime.compareTo(a.dateTime)); // сортировка

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
      transactions.sort(
        (a, b) => b.dateTime.compareTo(a.dateTime),
      ); // сортировка
      total = transactions.fold(0.0, (sum, t) => sum + t.amount);
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

    transactions.sort((a, b) => b.dateTime.compareTo(a.dateTime)); // сортировка
    total = transactions.fold(0.0, (sum, t) => sum + t.amount);
    notifyListeners();
  }
}
