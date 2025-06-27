import 'package:equatable/equatable.dart';

enum AnalysisType { income, expense }

abstract class AnalysisEvent extends Equatable {
  const AnalysisEvent();
  @override
  List<Object?> get props => [];
}

class LoadAnalysis extends AnalysisEvent {
  final int year;
  final AnalysisType type;
  const LoadAnalysis({required this.year, required this.type});
  @override
  List<Object?> get props => [year, type];
}

class ChangeYear extends AnalysisEvent {
  final int year;
  final AnalysisType type;
  const ChangeYear({required this.year, required this.type});
  @override
  List<Object?> get props => [year, type];
}

class ChangeYears extends AnalysisEvent {
  final List<int> years;
  final AnalysisType type;
  const ChangeYears({required this.years, required this.type});
  @override
  List<Object?> get props => [years, type];
}

class ChangePeriod extends AnalysisEvent {
  final DateTime from;
  final DateTime to;
  final AnalysisType type;
  const ChangePeriod({
    required this.from,
    required this.to,
    required this.type,
  });
  @override
  List<Object?> get props => [from, to, type];
}
