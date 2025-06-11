import 'package:cashnetic/utils/category_utils.dart';
import 'package:cashnetic/view_models/analysis/analysis_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: Colors.green.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: vm.availableYears.map((yr) {
                      final selected = yr == vm.selectedYear;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          checkmarkColor: Colors.white,
                          elevation: 0,
                          pressElevation: 0,
                          label: Text('$yr'),
                          selected: selected,
                          selectedColor: Colors.green,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : Colors.black,
                          ),
                          onSelected: (_) => vm.changeYear(yr),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Период
                Container(
                  color: Colors.green.withOpacity(0.2),
                  child: Column(
                    children: [
                      _PeriodRow(label: 'Период: начало', value: vm.startLabel),
                      _PeriodRow(label: 'Период: конец', value: vm.endLabel),
                    ],
                  ),
                ),

                // Сумма
                Container(
                  color: Colors.green.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Всего',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${result.total.toStringAsFixed(0)} ₽',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // График
                if (result.total > 0)
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      swapAnimationCurve: Curves.linear,
                      swapAnimationDuration: Duration(milliseconds: 1500),
                      PieChartData(
                        sections: result.data.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final c = entry.value;
                          final color =
                              vm.sectionColors[idx % vm.sectionColors.length];
                          return PieChartSectionData(
                            value: c.amount,
                            title: '${c.percent.toStringAsFixed(0)}%',
                            radius: 60,
                            color: color,
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
                const SizedBox(height: 48),

                // Цветная легенда
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: result.data.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final c = entry.value;
                      final color =
                          vm.sectionColors[idx % vm.sectionColors.length];
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${c.categoryTitle} (${c.percent.toStringAsFixed(0)}%)',
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Детализация
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: result.data.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final c = result.data[i];
                      final color = colorFor(
                        c.categoryTitle,
                        vm.sectionColors,
                      ).withOpacity(0.3);

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color.withOpacity(0.2),
                          child: Text(c.categoryIcon),
                        ),
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
