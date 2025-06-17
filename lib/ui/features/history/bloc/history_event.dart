import 'package:equatable/equatable.dart';

enum HistoryType { income, expense }

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
