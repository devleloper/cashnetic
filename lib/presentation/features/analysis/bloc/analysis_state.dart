import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class CategoryChartData {
  final int? id;
  final String categoryTitle;
  final String categoryIcon;
  final double amount;
  final double percent;
  final Color color;
  final DateTime? lastTransactionDate;
  CategoryChartData({
    this.id,
    required this.categoryTitle,
    required this.categoryIcon,
    required this.amount,
    required this.percent,
    required this.color,
    this.lastTransactionDate,
  });
}

class AnalysisResult {
  final List<CategoryChartData> data;
  final double total;
  final DateTime periodStart;
  final DateTime periodEnd;
  AnalysisResult({
    required this.data,
    required this.total,
    required this.periodStart,
    required this.periodEnd,
  });
}

abstract class AnalysisState extends Equatable {
  const AnalysisState();
  @override
  List<Object?> get props => [];
}

class AnalysisLoading extends AnalysisState {}

class AnalysisLoaded extends AnalysisState {
  final AnalysisResult result;
  final int selectedYear;
  final List<int> selectedYears;
  final List<int> availableYears;
  const AnalysisLoaded({
    required this.result,
    required this.selectedYear,
    required this.selectedYears,
    required this.availableYears,
  });
  @override
  List<Object?> get props => [
    result,
    selectedYear,
    selectedYears,
    availableYears,
  ];
}

class AnalysisError extends AnalysisState {
  final String message;
  const AnalysisError(this.message);
  @override
  List<Object?> get props => [message];
}
