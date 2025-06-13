import 'package:cashnetic/repositories/transactions/transactions_repository.dart';
import 'package:cashnetic/models/transactions/transaction_model.dart';

class MockTransactionsRepository implements TransactionsRepository {
  final List<TransactionModel> _mockData = [
    TransactionModel(
      id: 1,
      categoryId: 1,
      transactionDate: DateTime.now(),
      account: 'Сбербанк',
      categoryIcon: '🏠',
      categoryTitle: 'Аренда квартиры',
      amount: 100000,
      type: TransactionType.expense,
    ),
    TransactionModel(
      id: 2,
      categoryId: 2,
      transactionDate: DateTime.now(),
      account: 'Сбербанк',
      categoryIcon: '👗',
      categoryTitle: 'Одежда',
      amount: 100000,
      type: TransactionType.expense,
    ),
    TransactionModel(
      id: 3,
      categoryId: 3,
      transactionDate: DateTime.now(),
      account: 'Сбербанк',
      categoryIcon: '🐶',
      categoryTitle: 'На собачку',
      comment: 'Джек',
      amount: 100000,
      type: TransactionType.expense,
    ),
    TransactionModel(
      id: 4,
      categoryId: 3,
      transactionDate: DateTime.now(),
      account: 'Сбербанк',
      categoryIcon: '🐶',
      categoryTitle: 'На собачку',
      comment: 'Энни',
      amount: 100000,
      type: TransactionType.expense,
    ),
  ];

  @override
  Future<List<TransactionModel>> loadTransactions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockData;
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    _mockData.insert(0, transaction);
  }

  @override
  Future<void> deleteTransaction(int id) async {
    _mockData.removeWhere((t) => t.id == id);
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    final index = _mockData.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _mockData[index] = transaction;
    }
  }

  @override
  Future<List<TransactionModel>> loadByCategory(int categoryId) async {
    return _mockData.where((t) => t.categoryId == categoryId).toList();
  }
}
