import '../models/transactions/transaction_model.dart';

abstract class TransactionsRepository {
  Future<List<TransactionModel>> fetchTodayTransactions();
  Future<double> fetchTodayTotal();
}

class MockTransactionsRepository implements TransactionsRepository {
  final _mockData = [
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
  Future<List<TransactionModel>> fetchTodayTransactions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockData;
  }

  @override
  Future<double> fetchTodayTotal() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockData.fold<double>(0, (sum, item) => sum + item.amount);
  }
}
