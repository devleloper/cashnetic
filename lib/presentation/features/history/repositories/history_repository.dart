// history_repository.dart
import 'package:cashnetic/domain/entities/transaction.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'package:cashnetic/presentation/features/transactions/repositories/transactions_repository.dart';
import 'package:cashnetic/presentation/features/categories/repositories/categories_repository.dart';
import '../bloc/history_event.dart';

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
  final TransactionsRepository transactionRepository;
  final CategoriesRepository categoryRepository;

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
    // Получаем все транзакции за период
    final (txs, _) = await transactionRepository.getTransactions(
      from: from,
      to: to,
    );
    final cats = await categoryRepository.getCategories();
    
    // Фильтруем по типу (доходы/расходы)
    var filtered = txs.where((t) {
      final cat = cats.isNotEmpty
          ? cats.firstWhere(
              (c) => c.id == t.categoryId,
              orElse: () => cats.first,
            )
          : Category(
              id: 0,
              name: '—',
              emoji: '❓',
              isIncome: false,
              color: '#E0E0E0',
            );
      return type == HistoryType.expense
          ? cat.isIncome == false
          : cat.isIncome == true;
    }).toList();
    
    // Применяем сортировку
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
    
    // Применяем пагинацию ПОСЛЕ сортировки
    final start = page * pageSize;
    if (start >= filtered.length) {
      return []; // Нет данных для этой страницы
    }
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
