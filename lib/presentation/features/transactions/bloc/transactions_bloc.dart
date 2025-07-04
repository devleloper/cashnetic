import 'package:flutter_bloc/flutter_bloc.dart';
import 'transactions_event.dart';
import 'transactions_state.dart';
import 'package:cashnetic/presentation/features/transactions/repositories/transactions_repository.dart';
import 'package:cashnetic/presentation/features/categories/repositories/categories_repository.dart';
import 'package:cashnetic/domain/entities/transaction.dart';
import 'package:flutter/foundation.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final TransactionsRepository transactionRepository;
  final CategoriesRepository categoryRepository;

  TransactionsBloc({
    required this.transactionRepository,
    required this.categoryRepository,
  }) : super(TransactionsLoading()) {
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
    final txs = await transactionRepository.getTransactions(
      accountId: event.accountId,
      from: start,
      to: end,
    );
    final cats = await categoryRepository.getCategories();
    final filteredCats = cats
        .where((c) => c.isIncome == event.isIncome)
        .toList();
    debugPrint('[TransactionsBloc] Transactions count: ${txs.length}');
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
    // If there are no transactions, still show the UI (empty list)
    final total = txs.fold<double>(0, (sum, t) => sum + t.amount);
    emit(
      TransactionsLoaded(
        transactions: txs,
        categories: filteredCats,
        total: total,
        startDate: start,
        endDate: end,
        sort: TransactionsSort.date,
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
      // Сортировка по дате и времени транзакции (timestamp)
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
      ),
    );
  }

  Future<void> _onChangePeriod(
    TransactionsChangePeriod event,
    Emitter<TransactionsState> emit,
  ) async {
    // Звёздочка: корректировка дат
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
            : 1,
        startDate: start,
        endDate: end,
      ),
    );
  }
}
