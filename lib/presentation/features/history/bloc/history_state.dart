import 'package:equatable/equatable.dart';
import 'package:cashnetic/domain/entities/transaction.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();
  @override
  List<Object?> get props => [];
}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<Transaction> transactions;
  final double total;
  final String start;
  final String end;
  const HistoryLoaded({
    required this.transactions,
    required this.total,
    required this.start,
    required this.end,
  });
  @override
  List<Object?> get props => [transactions, total, start, end];
}

class HistoryError extends HistoryState {
  final String message;
  const HistoryError(this.message);
  @override
  List<Object?> get props => [message];
}
