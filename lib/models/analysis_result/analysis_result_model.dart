import 'package:flutter/material.dart';

class CategoryChartData {
  final String categoryTitle;
  final String categoryIcon;
  final double amount;
  final double percent;
  final Color color; // добавили

  CategoryChartData({
    required this.categoryTitle,
    required this.categoryIcon,
    required this.amount,
    required this.percent,
    required this.color,
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
