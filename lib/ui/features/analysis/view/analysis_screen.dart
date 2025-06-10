import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cashnetic/view_models/analysis/analysis_view_model.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AnalysisViewModel>();
    final result = vm.result;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: const Text('Анализ'),
      ),
      body: vm.loading || result == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 16),
                _PeriodRow(
                  label: 'Период: начало',
                  value: _formatDate(result.periodStart),
                ),
                _PeriodRow(
                  label: 'Период: конец',
                  value: _formatDate(result.periodEnd),
                ),
                _PeriodRow(
                  label: 'Сумма',
                  value: '${result.total.toStringAsFixed(0)} ₽',
                ),
                const SizedBox(height: 16),
                if (result.total > 0)
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: result.data.map((c) {
                          return PieChartSectionData(
                            value: c.amount,
                            title: '${c.percent.toStringAsFixed(0)}%',
                            radius: 60,
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
                  ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: result.data.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final c = result.data[i];
                      return ListTile(
                        leading: CircleAvatar(child: Text(c.categoryIcon)),
                        title: Text(c.categoryTitle),
                        subtitle: Text('${c.percent.toStringAsFixed(0)}%'),
                        trailing: Text('${c.amount.toStringAsFixed(0)} ₽'),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  String _formatDate(DateTime date) {
    return '${_monthName(date.month)} ${date.year}';
  }

  String _monthName(int month) {
    const months = [
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
    return months[month - 1];
  }
}

class _PeriodRow extends StatelessWidget {
  final String label, value;
  const _PeriodRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
