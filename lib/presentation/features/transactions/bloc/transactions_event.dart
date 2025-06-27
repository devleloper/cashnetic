import 'package:equatable/equatable.dart';

enum TransactionsSort { date, amount }

abstract class TransactionsEvent extends Equatable {
  const TransactionsEvent();
  @override
  List<Object?> get props => [];
}

class TransactionsLoad extends TransactionsEvent {
  final bool isIncome;
  final int accountId;
  final DateTime? startDate;
  final DateTime? endDate;
  const TransactionsLoad({
    required this.isIncome,
    required this.accountId,
    this.startDate,
    this.endDate,
  });
  @override
  List<Object?> get props => [isIncome, accountId, startDate, endDate];
}

class TransactionsChangeSort extends TransactionsEvent {
  final TransactionsSort sort;
  const TransactionsChangeSort(this.sort);
  @override
  List<Object?> get props => [sort];
}

class TransactionsChangePeriod extends TransactionsEvent {
  final DateTime startDate;
  final DateTime endDate;
  const TransactionsChangePeriod({
    required this.startDate,
    required this.endDate,
  });
  @override
  List<Object?> get props => [startDate, endDate];
}
