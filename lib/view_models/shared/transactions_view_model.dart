import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../repositories/transactions/transactions_repository.dart';

class TransactionsViewModel extends ChangeNotifier {
  final TransactionsRepository _repository;

  List<TransactionModel> _transactions = [];
  List<TransactionModel> get transactions => _transactions;

  TransactionsViewModel(this._repository);

  Future<void> loadTransactions() async {
    _transactions = await _repository.loadTransactions();
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _repository.addTransaction(transaction);
    _transactions.add(transaction);
    notifyListeners();
  }

  Future<void> deleteTransaction(int id) async {
    await _repository.deleteTransaction(id);
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}
