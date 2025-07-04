import 'package:cashnetic/presentation/features/account/bloc/account_state.dart'
    show DailyBalancePoint;
import 'package:cashnetic/generated/l10n.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'segmented_control.dart';

class AccountBalanceChart extends StatefulWidget {
  final List<DailyBalancePoint> points;
  const AccountBalanceChart({Key? key, required this.points}) : super(key: key);

  @override
  State<AccountBalanceChart> createState() => _AccountBalanceChartState();
}

class _AccountBalanceChartState extends State<AccountBalanceChart> {
  AccountChartMode _mode = AccountChartMode.days;

  List<DailyBalancePoint> get _chartData {
    if (widget.points.isEmpty) return [];
    if (_mode == AccountChartMode.days) {
      // Только дни с транзакциями
      return widget.points;
    } else {
      // Группировка по месяцам: суммируем доходы и расходы, отображаем все месяцы
      final byMonth = <String, List<DailyBalancePoint>>{};
      for (final p in widget.points) {
        final key = '${p.date.year}-${p.date.month}';
        byMonth.putIfAbsent(key, () => []).add(p);
      }
      final firstDate = widget.points.first.date;
      final lastDate = widget.points.last.date;
      final months = <DateTime>[];
      var current = DateTime(firstDate.year, firstDate.month, 1);
      final end = DateTime(lastDate.year, lastDate.month, 1);
      while (!current.isAfter(end)) {
        months.add(current);
        if (current.month == 12) {
          current = DateTime(current.year + 1, 1, 1);
        } else {
          current = DateTime(current.year, current.month + 1, 1);
        }
      }
      final result = <DailyBalancePoint>[];
      for (final month in months) {
        final key = '${month.year}-${month.month}';
        final list = byMonth[key] ?? [];
        final income = list.fold<double>(0, (sum, e) => sum + e.income);
        final expense = list.fold<double>(0, (sum, e) => sum + e.expense);
        result.add(DailyBalancePoint(month, income, expense));
      }
      return result;
    }
  }

  @override
  Widget build(BuildContext context) {
    final points = _chartData;
    if (points.isEmpty) {
      return Center(child: Text(S.of(context).noDataForChart));
    }
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
    return Column(
      children: [
        SegmentedControl(
          selectedMode: _mode,
          onChanged: (mode) {
            setState(() {
              _mode = mode;
            });
          },
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
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
                        TextStyle(
                          fontWeight: FontWeight.bold,
                          color: rod.color,
                        ),
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
                        if (_mode == AccountChartMode.days) {
                          // Подписи только под днями с транзакциями
                          return SizedBox(
                            width: 40,
                            child: SideTitleWidget(
                              meta: meta,
                              child: Text(
                                '${dt.day.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        } else {
                          // Для месяцев — подпись ММ.ГГ
                          return SizedBox(
                            width: 40,
                            child: SideTitleWidget(
                              meta: meta,
                              child: Text(
                                '${dt.month.toString().padLeft(2, '0')}.${dt.year % 100}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }
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
                          child: Text(
                            text,
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
              ),
              swapAnimationDuration: const Duration(milliseconds: 250),
              swapAnimationCurve: Curves.easeInOut,
            ),
          ),
        ),
      ],
    );
  }
}
