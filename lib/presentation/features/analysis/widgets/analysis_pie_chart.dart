import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalysisPieChart extends StatelessWidget {
  final List<dynamic> data;
  const AnalysisPieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 200,
      child: PieChart(
        swapAnimationCurve: Curves.easeInOutCubic,
        swapAnimationDuration: const Duration(milliseconds: 1500),
        PieChartData(
          sections: data.asMap().entries.map((entry) {
            final c = entry.value;
            return PieChartSectionData(
              value: c.amount,
              title: '${c.percent.toStringAsFixed(0)}%',
              radius: 60,
              color: c.color,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
          centerSpaceRadius: 50,
          sectionsSpace: 2,
          borderData: FlBorderData(show: false),
          pieTouchData: PieTouchData(enabled: false),
        ),
      ),
    );
  }
}
