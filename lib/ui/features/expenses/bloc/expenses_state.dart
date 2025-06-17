import '../../../../domain/entities/transaction.dart';

abstract class ExpensesState {}

class ExpensesInitial extends ExpensesState {}

class ExpensesLoading extends ExpensesState {}

class ExpensesLoaded extends ExpensesState {
  final List<Transaction> transactions;
  final double total;

  ExpensesLoaded({required this.transactions})
    : total = transactions.fold(0, (sum, t) => sum + t.amount);
}

class ExpensesError extends ExpensesState {
  final String message;

  ExpensesError(this.message);
}
