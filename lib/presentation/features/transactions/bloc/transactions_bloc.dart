import 'package:flutter_bloc/flutter_bloc.dart';
import 'transactions_event.dart';
import 'transactions_state.dart';
import 'package:cashnetic/presentation/features/transactions/repositories/transactions_repository.dart';
import 'package:cashnetic/presentation/features/categories/repositories/categories_repository.dart';
import 'package:cashnetic/domain/entities/transaction.dart';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import 'package:cashnetic/domain/constants/constants.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final TransactionsRepository transactionRepository;
  final CategoriesRepository categoryRepository;

  TransactionsBloc({
    required this.transactionRepository,
    required this.categoryRepository,
  }) : super(TransactionsInitial()) {
    on<TransactionsLoad>(_onLoad);
    on<TransactionsChangeSort>(_onChangeSort);
    on<TransactionsChangePeriod>(_onChangePeriod);
  }

  DateTime _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 0, 0, 0);
  DateTime _endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59);

  Future<void> _onLoad(
    TransactionsLoad event,
    Emitter<TransactionsState> emit,
  ) async {
    final now = DateTime.now();
    final start = event.startDate ?? _startOfDay(now);
    final end = event.endDate ?? _endOfDay(now);
    debugPrint(
      '[TransactionsBloc] _onLoad: isIncome=${event.isIncome}, accountId=${event.accountId}, start=$start, end=$end',
    );
    emit(TransactionsLoading());
    final (txs, isLocalFallback) = await transactionRepository.getTransactions(
      accountId: event.accountId,
      from: start,
      to: end,
    );
    final cats = await categoryRepository.getCategories();
    final filteredCats = cats
        .where((c) => c.isIncome == event.isIncome)
        .toList();
    // Filter transactions by category.isIncome
    final filteredTxs = txs.where((t) {
      final cat = cats.firstWhereOrNull((c) => c.id == t.categoryId);
      return cat != null && cat.isIncome == event.isIncome;
    }).toList();
    debugPrint(
      '[TransactionsBloc] Transactions count:  [33m${filteredTxs.length} [0m',
    );
    debugPrint('[TransactionsBloc] Categories count: ${cats.length}');
    debugPrint(
      '[TransactionsBloc] Filtered categories count: ${filteredCats.length}',
    );
    if (filteredCats.isEmpty) {
      debugPrint(
        '[TransactionsBloc] Emitting TransactionsError: filteredCats.isEmpty=true',
      );
      emit(TransactionsError('Failed to load data'));
      return;
    }
    // Если нет транзакций, показываем пустой список (не ошибку)
    final total = filteredTxs.fold<double>(0, (sum, t) => sum + t.amount);
    emit(
      TransactionsLoaded(
        transactions: filteredTxs,
        categories: filteredCats,
        total: total,
        startDate: start,
        endDate: end,
        sort: TransactionsSort.date,
        isLocalFallback: isLocalFallback,
      ),
    );
  }

  void _onChangeSort(
    TransactionsChangeSort event,
    Emitter<TransactionsState> emit,
  ) {
    if (state is! TransactionsLoaded) return;
    final current = state as TransactionsLoaded;
    List<Transaction> sorted = [...current.transactions];
    if (event.sort == TransactionsSort.amount) {
      sorted.sort((a, b) => b.amount.compareTo(a.amount));
    } else {
      // Sort by transaction date and time (timestamp)
      sorted.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }
    emit(
      TransactionsLoaded(
        transactions: sorted,
        categories: current.categories,
        total: current.total,
        startDate: current.startDate,
        endDate: current.endDate,
        sort: event.sort,
        isLocalFallback: current.isLocalFallback,
      ),
    );
  }

  Future<void> _onChangePeriod(
    TransactionsChangePeriod event,
    Emitter<TransactionsState> emit,
  ) async {
    // Star: adjust dates
    DateTime start = event.startDate;
    DateTime end = event.endDate;
    if (end.isBefore(start)) {
      start = end;
    }
    if (start.isAfter(end)) {
      end = start;
    }
    add(
      TransactionsLoad(
        isIncome: (state as TransactionsLoaded).categories.isNotEmpty
            ? (state as TransactionsLoaded).categories.first.isIncome
            : false,
        accountId: (state as TransactionsLoaded).transactions.isNotEmpty
            ? (state as TransactionsLoaded).transactions.first.accountId
            : ALL_ACCOUNTS_ID,
        startDate: start,
        endDate: end,
      ),
    );
  }
}
