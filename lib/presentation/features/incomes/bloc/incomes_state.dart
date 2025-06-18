import 'package:equatable/equatable.dart';
import 'package:cashnetic/domain/entities/transaction.dart';

abstract class IncomesState extends Equatable {
  const IncomesState();
  @override
  List<Object?> get props => [];
}

class IncomesInitial extends IncomesState {}

class IncomesLoading extends IncomesState {}

class IncomesLoaded extends IncomesState {
  final List<Transaction> incomes;
  final double total;
  final DateTime date;

  const IncomesLoaded({
    required this.incomes,
    required this.total,
    required this.date,
  });

  @override
  List<Object?> get props => [incomes, total, date];
}

class IncomesError extends IncomesState {
  final String message;
  const IncomesError(this.message);
  @override
  List<Object?> get props => [message];
}

class IncomesRefreshing extends IncomesState {
  final List<Transaction> incomes;
  final double total;
  final DateTime date;

  const IncomesRefreshing({
    required this.incomes,
    required this.total,
    required this.date,
  });

  @override
  List<Object?> get props => [incomes, total, date];
}
