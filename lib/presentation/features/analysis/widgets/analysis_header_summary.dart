import 'package:flutter/material.dart';
import '../widgets/period_row.dart';

class AnalysisHeaderSummary extends StatelessWidget {
  final List<int> availableYears;
  final List<int> selectedYears;
  final void Function(int year, bool selected) onYearSelected;
  final DateTime periodStart;
  final DateTime periodEnd;
  final num total;

  const AnalysisHeaderSummary({
    super.key,
    required this.availableYears,
    required this.selectedYears,
    required this.onYearSelected,
    required this.periodStart,
    required this.periodEnd,
    required this.total,
  });

  String _monthYear(DateTime dt) {
    const names = [
      'январь',
      'февраль',
      'март',
      'апрель',
      'май',
      'июнь',
      'июль',
      'август',
      'сентябрь',
      'октябрь',
      'ноябрь',
      'декабрь',
    ];
    return '${names[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.green.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              children: availableYears.map((yr) {
                final selected = selectedYears.contains(yr);
                return FilterChip(
                  elevation: 0,
                  checkmarkColor: Colors.white,
                  label: Text('$yr'),
                  selected: selected,
                  selectedColor: Colors.green,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.black,
                  ),
                  onSelected: (val) => onYearSelected(yr, val),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            PeriodRow(label: 'Период: начало', value: _monthYear(periodStart)),
            PeriodRow(label: 'Период: конец', value: _monthYear(periodEnd)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Всего',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  '${total.toStringAsFixed(0)} ₽',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
