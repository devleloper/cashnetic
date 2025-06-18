import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashnetic/domain/repositories/transaction_repository.dart';
import 'package:cashnetic/domain/entities/transaction.dart';
import 'package:intl/intl.dart';
import 'history_event.dart';
import 'history_state.dart';
import 'package:cashnetic/domain/repositories/category_repository.dart';
import 'package:cashnetic/domain/entities/category.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final TransactionRepository transactionRepository;
  final CategoryRepository categoryRepository;

  HistoryBloc({
    required this.transactionRepository,
    required this.categoryRepository,
  }) : super(HistoryLoading()) {
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
    // Получаем категории для фильтрации
    final catResult = await categoryRepository.getAllCategories();
    final categories = catResult.fold((_) => <dynamic>[], (cats) => cats);
    // Фильтруем по типу
    final filtered = txs.where((t) {
      final cat = categories.firstWhere(
        (c) => c.id == t.categoryId,
        orElse: () => Category(
          id: 0,
          name: 'Неизвестно',
          emoji: '❓',
          isIncome: false,
          color: '#E0E0E0',
        ),
      );
      return event.type == HistoryType.expense
          ? cat.isIncome == false
          : cat.isIncome == true;
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
