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
  DateTime? _selectedMonth; // для режима дней
  int? _selectedYear; // для режима месяцев

  List<DailyBalancePoint> get _chartData {
    if (widget.points.isEmpty) return [];
    if (_mode == AccountChartMode.days) {
      final month = _selectedMonth ?? DateTime.now();
      final points = widget.points
          .where(
            (e) => e.date.year == month.year && e.date.month == month.month,
          )
          .toList();
      return points;
    } else {
      // Группировка по месяцам: суммируем доходы и расходы, отображаем все месяцы выбранного года
      final byMonth = <String, List<DailyBalancePoint>>{};
      for (final p in widget.points) {
        final key = '${p.date.year}-${p.date.month}';
        byMonth.putIfAbsent(key, () => []).add(p);
      }
      // Найти минимальную и максимальную дату среди всех транзакций
      final minDate = widget.points
          .map((e) => e.date)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      final maxDate = widget.points
          .map((e) => e.date)
          .reduce((a, b) => a.isAfter(b) ? a : b);
      final years = List.generate(
        maxDate.year - minDate.year + 1,
        (i) => minDate.year + i,
      );
      final year = _selectedYear ?? minDate.year;
      final months = <DateTime>[];
      for (int m = 1; m <= 12; m++) {
        final dt = DateTime(year, m, 1);
        final isAfterOrSameMin =
            (dt.year > minDate.year) ||
            (dt.year == minDate.year && dt.month >= minDate.month);
        final isBeforeOrSameMax =
            (dt.year < maxDate.year) ||
            (dt.year == maxDate.year && dt.month <= maxDate.month);
        if (isAfterOrSameMin && isBeforeOrSameMax) {
          months.add(dt);
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

  Future<void> _pickMonth(BuildContext context) async {
    final now = DateTime.now();
    final initial = _selectedMonth != null
        ? DateTime(_selectedMonth!.year, _selectedMonth!.month, 1)
        : DateTime(now.year, now.month, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      helpText: 'Выберите месяц',
      fieldLabelText: 'Месяц',
      fieldHintText: 'ММ.ГГГГ',
      selectableDayPredicate: (date) => date.day == 1,
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  Future<void> _pickYear(BuildContext context) async {
    final now = DateTime.now();
    final initial = _selectedYear ?? now.year;
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(initial, 1, 1),
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      helpText: 'Выберите год',
      fieldLabelText: 'Год',
      fieldHintText: 'ГГГГ',
      selectableDayPredicate: (date) => date.month == 1 && date.day == 1,
    );
    if (picked != null) {
      setState(() {
        _selectedYear = picked.year;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final points = _chartData;
    // Вычисляем подпись справа
    String rightLabel = '';
    Widget? rightWidget;
    if (_mode == AccountChartMode.days) {
      final months =
          widget.points
              .map((e) => DateTime(e.date.year, e.date.month))
              .toSet()
              .toList()
            ..sort((a, b) => a.compareTo(b));
      if (_selectedMonth != null) {
        rightLabel = DateFormat('LLLL yyyy', 'en').format(_selectedMonth!);
      } else if (months.length == 1) {
        rightLabel = DateFormat('LLLL yyyy', 'en').format(months.first);
      } else if (months.isNotEmpty) {
        rightLabel =
            '${DateFormat('LLL', 'en').format(months.first)}–${DateFormat('LLL yyyy', 'en').format(months.last)}';
      }
      rightWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (rightLabel.isNotEmpty)
            Text(
              rightLabel,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          IconButton(
            icon: const Icon(Icons.calendar_today, size: 20),
            onPressed: () => _pickMonth(context),
            tooltip: 'Выбрать месяц',
          ),
        ],
      );
    } else {
      final years = widget.points.map((e) => e.date.year).toSet().toList()
        ..sort();
      if (_selectedYear != null) {
        rightLabel = _selectedYear.toString();
      } else if (years.length == 1) {
        rightLabel = years.first.toString();
      } else if (years.isNotEmpty) {
        rightLabel = '${years.first}–${years.last}';
      }
      rightWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (rightLabel.isNotEmpty)
            Text(
              rightLabel,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          IconButton(
            icon: const Icon(Icons.calendar_today, size: 20),
            onPressed: () => _pickYear(context),
            tooltip: 'Выбрать год',
          ),
        ],
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: SegmentedControl(
                  selectedMode: _mode,
                  onChanged: (mode) {
                    setState(() {
                      _mode = mode;
                      // Сброс выбранного периода при смене режима
                      if (_mode == AccountChartMode.days) {
                        _selectedYear = null;
                      } else {
                        _selectedMonth = null;
                      }
                    });
                  },
                ),
              ),
              if (rightWidget != null)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: rightWidget,
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (points.isEmpty)
          Center(child: Text(S.of(context).noDataForChart))
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: MediaQuery.of(context).size.width, // всегда на всю ширину
              height: 300,
              child: BarChart(
                BarChartData(
                  maxY:
                      points
                          .map(
                            (e) => e.income > e.expense ? e.income : e.expense,
                          )
                          .reduce((a, b) => a > b ? a : b) *
                      1.2,
                  barGroups: points.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final pt = entry.value;
                    return BarChartGroupData(
                      x: idx,
                      barsSpace: 4,
                      barRods: [
                        BarChartRodData(
                          toY: pt.expense,
                          color: Colors.orange,
                          width: 12,
                        ),
                        BarChartRodData(
                          toY: pt.income,
                          color: Colors.green,
                          width: 12,
                        ),
                      ],
                    );
                  }).toList(),
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
                          '$label  A${DateFormat('dd.MM').format(date)}\n',
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
