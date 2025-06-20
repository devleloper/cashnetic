import 'package:flutter_bloc/flutter_bloc.dart';
import 'transactions_event.dart';
import 'transactions_state.dart';
import 'package:cashnetic/domain/repositories/transaction_repository.dart';
import 'package:cashnetic/domain/repositories/category_repository.dart';
import 'package:cashnetic/domain/entities/transaction.dart';
import 'package:cashnetic/domain/entities/category.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final TransactionRepository transactionRepository;
  final CategoryRepository categoryRepository;

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
    emit(TransactionsLoading());
    final now = DateTime.now();
    final start = event.startDate ?? _startOfDay(now);
    final end = event.endDate ?? _endOfDay(now);
    final txResult = await transactionRepository.getTransactionsByPeriod(
      1, // TODO: accountId
      start,
      end,
    );
    final catResult = await categoryRepository.getCategoriesByIsIncome(
      event.isIncome,
    );
    if (txResult.isLeft() || catResult.isLeft()) {
      emit(TransactionsError('Ошибка загрузки данных'));
      return;
    }
    final txs = txResult.getOrElse(() => []);
    final cats = catResult.getOrElse(() => []);
    final filtered = txs
        .where((t) => cats.any((c) => c.id == t.categoryId))
        .toList();
    final total = filtered.fold<double>(0, (sum, t) => sum + t.amount);
    emit(
      TransactionsLoaded(
        transactions: filtered,
        categories: cats,
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
        startDate: start,
        endDate: end,
      ),
    );
  }
}
