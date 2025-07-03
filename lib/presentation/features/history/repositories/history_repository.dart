// history_repository.dart
import 'package:dartz/dartz.dart';
import 'package:cashnetic/domain/entities/transaction.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'package:cashnetic/domain/repositories/transaction_repository.dart';
import 'package:cashnetic/domain/repositories/category_repository.dart';
import 'package:cashnetic/domain/failures/failure.dart';
import '../bloc/history_event.dart';
import '../bloc/history_state.dart';

abstract interface class HistoryRepository {
  Future<List<Transaction>> getTransactionsByPeriod({
    required DateTime from,
    required DateTime to,
    required HistoryType type,
    required HistorySort sort,
    required int page,
    required int pageSize,
  });
  double getTotal(List<Transaction> transactions);
  Map<String, String> getPeriodStrings(List<Transaction> transactions);
}

class HistoryRepositoryImpl implements HistoryRepository {
  final TransactionRepository transactionRepository;
  final CategoryRepository categoryRepository;

  HistoryRepositoryImpl({
    required this.transactionRepository,
    required this.categoryRepository,
  });

  @override
  Future<List<Transaction>> getTransactionsByPeriod({
    required DateTime from,
    required DateTime to,
    required HistoryType type,
    required HistorySort sort,
    required int page,
    required int pageSize,
  }) async {
    final txResult = await transactionRepository.getTransactionsByPeriod(
      0,
      from,
      to,
    );
    final txs = txResult.fold((_) => <Transaction>[], (txs) => txs);
    final catResult = await categoryRepository.getAllCategories();
    final categories = catResult.fold((_) => <Category>[], (cats) => cats);
    // Фильтруем по типу
    var filtered = txs.where((t) {
      final cat = categories.firstWhere(
        (c) => c.id == t.categoryId,
        orElse: () => Category(
          id: 0,
          name: 'Unknown',
          emoji: '❓',
          isIncome: false,
          color: '#E0E0E0',
        ),
      );
      return type == HistoryType.expense
          ? cat.isIncome == false
          : cat.isIncome == true;
    }).toList();
    // Сортировка
    switch (sort) {
      case HistorySort.dateDesc:
        filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
      case HistorySort.dateAsc:
        filtered.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        break;
      case HistorySort.amountDesc:
        filtered.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case HistorySort.amountAsc:
        filtered.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case HistorySort.category:
        filtered.sort(
          (a, b) => (a.categoryId ?? 0).compareTo(b.categoryId ?? 0),
        );
        break;
    }
    // Пагинация
    final start = page * pageSize;
    final end = (page + 1) * pageSize;
    return filtered.skip(start).take(pageSize).toList();
  }

  @override
  double getTotal(List<Transaction> transactions) {
    return transactions.fold<double>(0, (sum, t) => sum + t.amount);
  }

  @override
  Map<String, String> getPeriodStrings(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return {'start': '—', 'end': '—'};
    }
    transactions.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final start = transactions.first.timestamp;
    final end = transactions.last.timestamp;
    return {
      'start':
          '${start.day.toString().padLeft(2, '0')}.${start.month.toString().padLeft(2, '0')}.${start.year}',
      'end':
          '${end.day.toString().padLeft(2, '0')}.${end.month.toString().padLeft(2, '0')}.${end.year}',
    };
  }
}
