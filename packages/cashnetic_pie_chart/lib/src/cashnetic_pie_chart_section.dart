import 'package:flutter/material.dart';

/// Модель сектора для передачи данных в CashneticPieChart
class CashneticPieChartSection {
  final double value;
  final String label;
  final Color color;
  final double? percent; // если нужно явно передавать процент

  const CashneticPieChartSection({
    required this.value,
    required this.label,
    required this.color,
    this.percent,
  });
}
