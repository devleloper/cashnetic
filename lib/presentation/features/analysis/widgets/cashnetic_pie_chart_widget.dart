import 'package:flutter/material.dart';
import 'package:cashnetic_pie_chart/cashnetic_pie_chart.dart';

class AnalysisPieChartData {
  final double amount;
  final String categoryTitle;
  final Color color;
  final double percent;

  AnalysisPieChartData({
    required this.amount,
    required this.categoryTitle,
    required this.color,
    required this.percent,
  });
}

class CashneticPieChartWidget extends StatelessWidget {
  final List<AnalysisPieChartData> data;
  final double height;

  const CashneticPieChartWidget({
    Key? key,
    required this.data,
    this.height = 220,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();
    return CashneticPieChart(
      sections: data
          .map(
            (e) => CashneticPieChartSection(
              value: e.amount,
              label: e.categoryTitle,
              color: e.color,
              percent: e.percent,
            ),
          )
          .toList(),
      height: height,
    );
  }
}
