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
