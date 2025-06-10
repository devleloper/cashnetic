import 'package:cashnetic/repositories/transactions/transactions_repository.dart';
import 'package:cashnetic/models/transactions/transaction_model.dart';

class MockTransactionsRepository implements TransactionsRepository {
  final List<TransactionModel> _mockData = [
    TransactionModel(
      id: 1,
      categoryIcon: '🏠',
      categoryTitle: 'Аренда квартиры',
      amount: 100000,
    ),
    TransactionModel(
      id: 2,
      categoryIcon: '👗',
      categoryTitle: 'Одежда',
      amount: 100000,
    ),
    TransactionModel(
      id: 3,
      categoryIcon: '🐶',
      categoryTitle: 'На собачку',
      comment: 'Джек',
      amount: 100000,
    ),
    TransactionModel(
      id: 4,
      categoryIcon: '🐶',
      categoryTitle: 'На собачку',
      comment: 'Энни',
      amount: 100000,
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
}
