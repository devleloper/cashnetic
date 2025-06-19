import 'package:equatable/equatable.dart';
import 'package:cashnetic/domain/entities/transaction.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'transactions_event.dart';

abstract class TransactionsState extends Equatable {
  const TransactionsState();
  @override
  List<Object?> get props => [];
}

class TransactionsLoading extends TransactionsState {}

class TransactionsLoaded extends TransactionsState {
  final List<Transaction> transactions;
  final List<Category> categories;
  final double total;
  final DateTime startDate;
  final DateTime endDate;
  final TransactionsSort sort;
  const TransactionsLoaded({
    required this.transactions,
    required this.categories,
    required this.total,
    required this.startDate,
    required this.endDate,
    required this.sort,
  });
  @override
  List<Object?> get props => [
    transactions,
    categories,
    total,
    startDate,
    endDate,
    sort,
  ];
}

class TransactionsError extends TransactionsState {
  final String message;
  const TransactionsError(this.message);
  @override
  List<Object?> get props => [message];
}
