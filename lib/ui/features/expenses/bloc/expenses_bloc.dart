import 'package:cashnetic/domain/repositories/transaction_repository.dart';
import 'package:cashnetic/data/repositories/mocks/mocked_transaction_repository.dart';
import 'package:cashnetic/ui/features/expenses/bloc/expenses_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'expenses_state.dart';

class ExpensesBloc extends Bloc<ExpensesEvent, ExpensesState> {
  final TransactionRepository _repository;

  ExpensesBloc({TransactionRepository? repository})
    : _repository = repository ?? MockedTransactionRepository(),
      super(ExpensesInitial()) {
    on<LoadExpensesEvent>(_onLoad);
  }

  Future<void> _onLoad(
    LoadExpensesEvent event,
    Emitter<ExpensesState> emit,
  ) async {
    emit(ExpensesLoading());

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await _repository.getTransactionsByPeriod(
      1,
      startOfDay,
      endOfDay,
    );

    result.fold(
      (failure) => emit(ExpensesError(failure.message)),
      (transactions) => emit(
        ExpensesLoaded(
          transactions: transactions.where((t) => t.amount > 0).toList(),
        ),
      ),
    );
  }
}
