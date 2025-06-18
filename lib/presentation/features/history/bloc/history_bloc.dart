import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashnetic/domain/repositories/transaction_repository.dart';
import 'package:cashnetic/domain/entities/transaction.dart';
import 'package:intl/intl.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final TransactionRepository transactionRepository;

  HistoryBloc({required this.transactionRepository}) : super(HistoryLoading()) {
    on<LoadHistory>(_onLoadHistory);
  }

  Future<void> _onLoadHistory(
    LoadHistory event,
    Emitter<HistoryState> emit,
  ) async {
    emit(HistoryLoading());
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));
    final txResult = await transactionRepository.getTransactionsByPeriod(
      1,
      monthAgo,
      now,
    ); // accountId=1 (TODO: поддержка мультиаккаунтов)
    final txs = txResult.fold((_) => <Transaction>[], (txs) => txs);
    final filtered = txs.where((t) {
      // TODO: фильтрация по типу (income/expense) через категории, если потребуется
      return t.timestamp.isAfter(monthAgo) && t.timestamp.isBefore(now);
    }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final total = filtered.fold<double>(0, (sum, t) => sum + t.amount);
    final start = filtered.isNotEmpty
        ? DateFormat('dd.MM.yyyy').format(filtered.last.timestamp)
        : '—';
    final end = filtered.isNotEmpty
        ? DateFormat('dd.MM.yyyy').format(filtered.first.timestamp)
        : '—';
    emit(
      HistoryLoaded(
        transactions: filtered,
        total: total,
        start: start,
        end: end,
      ),
    );
  }
}
