import 'package:cashnetic/generated/l10n.dart';
import 'package:cashnetic/presentation/features/account/bloc/account_state.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BalanceBarChart extends StatelessWidget {
  final List<DailyBalancePoint> points;
  const BalanceBarChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty)
      return Center(child: Text(S.of(context).noDataForChart));
    final maxVal = points
        .map((e) => e.income > e.expense ? e.income : e.expense)
        .reduce((a, b) => a > b ? a : b);
    final groups = points.asMap().entries.map((entry) {
      final idx = entry.key;
      final pt = entry.value;
      return BarChartGroupData(
        x: idx,
        barsSpace: 4,
        barRods: [
          BarChartRodData(toY: pt.expense, color: Colors.orange, width: 12),
          BarChartRodData(toY: pt.income, color: Colors.green, width: 12),
        ],
      );
    }).toList();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: groups.length * 28.0 + 40,
        height: 300,
        child: BarChart(
          BarChartData(
            maxY: maxVal * 1.2,
            barGroups: groups,
            alignment: BarChartAlignment.start,
            groupsSpace: 12,
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (group) => Colors.white,
                getTooltipItem: (group, _, rod, rodIndex) {
                  final date = points[group.x.toInt()].date;
                  final value = rod.toY.toStringAsFixed(0);
                  final label = rodIndex == 0
                      ? S.of(context).expense
                      : S.of(context).income;
                  return BarTooltipItem(
                    '$label ${DateFormat('dd.MM').format(date)}\n',
                    TextStyle(fontWeight: FontWeight.bold, color: rod.color),
                    children: [
                      TextSpan(
                        text: value,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  interval: 1,
                  getTitlesWidget: (val, meta) {
                    final idx = val.toInt();
                    if (idx < 0 || idx >= points.length)
                      return const SizedBox.shrink();
                    final dt = points[idx].date;
                    return SizedBox(
                      width: 40,
                      child: SideTitleWidget(
                        meta: meta,
                        child: Text(
                          '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 48,
                  getTitlesWidget: (value, meta) {
                    String text = value >= 1000
                        ? '${(value / 1000).toStringAsFixed(1)}K'
                        : value.toInt().toString();
                    return SideTitleWidget(
                      meta: meta,
                      space: 8,
                      child: Text(text, style: const TextStyle(fontSize: 12)),
                    );
                  },
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
          ),
          swapAnimationDuration: const Duration(milliseconds: 250),
          swapAnimationCurve: Curves.easeInOut,
        ),
      ),
    );
  }
}
