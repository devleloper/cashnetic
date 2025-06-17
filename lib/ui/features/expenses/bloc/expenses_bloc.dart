import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashnetic/domain/repositories/transaction_repository.dart';
import 'package:cashnetic/domain/entities/transaction.dart';
import 'expenses_event.dart';
import 'expenses_state.dart';

class ExpensesBloc extends Bloc<ExpensesEvent, ExpensesState> {
  final TransactionRepository transactionRepository;

  ExpensesBloc({required this.transactionRepository})
    : super(ExpensesLoading()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<AddExpense>(_onAddExpense);
    on<DeleteExpense>(_onDeleteExpense);
    on<UpdateExpense>(_onUpdateExpense);
  }

  Future<void> _onLoadExpenses(
    LoadExpenses event,
    Emitter<ExpensesState> emit,
  ) async {
    emit(ExpensesLoading());
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final txResult = await transactionRepository.getTransactionsByPeriod(
      1,
      todayStart,
      todayEnd,
    ); // accountId=1 (TODO: поддержка мультиаккаунтов)
    final txs = txResult
        .fold((_) => <Transaction>[], (txs) => txs)
        .where(
          (t) =>
              t.timestamp.isAfter(todayStart) && t.timestamp.isBefore(todayEnd),
        )
        .toList();
    final expenses =
        txs; // предполагается, что фильтрация по типу расхода делается через категории
    final total = expenses.fold<double>(0, (sum, t) => sum + t.amount);
    emit(ExpensesLoaded(transactions: expenses, total: total));
  }

  Future<void> _onAddExpense(
    AddExpense event,
    Emitter<ExpensesState> emit,
  ) async {
    // event.transaction должен быть типа Transaction
    // Здесь должна быть логика добавления транзакции через репозиторий
    add(LoadExpenses());
  }

  Future<void> _onDeleteExpense(
    DeleteExpense event,
    Emitter<ExpensesState> emit,
  ) async {
    // Здесь должна быть логика удаления транзакции через репозиторий
    add(LoadExpenses());
  }

  Future<void> _onUpdateExpense(
    UpdateExpense event,
    Emitter<ExpensesState> emit,
  ) async {
    // Здесь должна быть логика обновления транзакции через репозиторий
    add(LoadExpenses());
  }
}
