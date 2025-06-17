import 'package:equatable/equatable.dart';
import 'package:cashnetic/domain/entities/transaction.dart';

abstract class ExpensesState extends Equatable {
  const ExpensesState();
  @override
  List<Object?> get props => [];
}

class ExpensesLoading extends ExpensesState {}

class ExpensesLoaded extends ExpensesState {
  final List<Transaction> transactions;
  final double total;
  const ExpensesLoaded({required this.transactions, required this.total});
  @override
  List<Object?> get props => [transactions, total];
}

class ExpensesError extends ExpensesState {
  final String message;
  const ExpensesError(this.message);
  @override
  List<Object?> get props => [message];
}
