import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../repositories/transactions/transactions_repository.dart';

class TransactionsViewModel extends ChangeNotifier {
  final TransactionsRepository _repository;

  List<TransactionModel> _transactions = [];
  List<TransactionModel> get transactions => _transactions;

  List<TransactionModel> get incomes =>
      _transactions.where((t) => t.type == TransactionType.income).toList();

  List<TransactionModel> get expenses =>
      _transactions.where((t) => t.type == TransactionType.expense).toList();

  TransactionsViewModel(this._repository);

  Future<void> loadTransactions() async {
    _transactions = await _repository.loadTransactions();
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _repository.addTransaction(transaction);
    _transactions = [..._transactions, transaction]; // новый список
    notifyListeners();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _repository.updateTransaction(transaction);
    _transactions = _transactions
        .map((t) => t.id == transaction.id ? transaction : t)
        .toList(); // заменяем элемент
    notifyListeners();
  }

  Future<void> deleteTransaction(int id) async {
    await _repository.deleteTransaction(id);
    _transactions = _transactions
        .where((t) => t.id != id)
        .toList(); // фильтрация
    notifyListeners();
  }
}
