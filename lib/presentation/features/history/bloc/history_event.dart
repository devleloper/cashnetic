import 'package:equatable/equatable.dart';

enum HistoryType { income, expense }

enum HistorySort { dateDesc, dateAsc, amountDesc, amountAsc, category }

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();
  @override
  List<Object?> get props => [];
}

class LoadHistory extends HistoryEvent {
  final HistoryType type;
  const LoadHistory(this.type);
  @override
  List<Object?> get props => [type];
}

class ChangePeriod extends HistoryEvent {
  final DateTime from;
  final DateTime to;
  final HistoryType type;
  const ChangePeriod(this.from, this.to, this.type);
  @override
  List<Object?> get props => [from, to, type];
}

class ChangeSort extends HistoryEvent {
  final HistorySort sort;
  const ChangeSort(this.sort);
  @override
  List<Object?> get props => [sort];
}

class LoadMoreHistory extends HistoryEvent {}
