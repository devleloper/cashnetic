import 'package:cashnetic/ui/features/analysis/bloc/analysis_bloc.dart';
import 'package:cashnetic/ui/features/analysis/bloc/analysis_event.dart';
import 'package:cashnetic/ui/features/analysis/bloc/analysis_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalysisScreen extends StatelessWidget {
  final AnalysisType type;
  const AnalysisScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalysisBloc, AnalysisState>(
      builder: (context, state) {
        if (state is AnalysisLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is AnalysisError) {
          return Scaffold(body: Center(child: Text(state.message)));
        }
        if (state is! AnalysisLoaded) {
          return const SizedBox.shrink();
        }
        final result = state.result;
        return Scaffold(
          appBar: AppBar(
            leading: const BackButton(color: Colors.white),
            title: Text(
              type == AnalysisType.expense
                  ? 'Анализ расходов'
                  : 'Анализ доходов',
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: Colors.green.withOpacity(0.2),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: state.availableYears.map((yr) {
                    final selected = yr == state.selectedYear;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        elevation: 0,
                        pressElevation: 0,
                        checkmarkColor: Colors.white,
                        label: Text('$yr'),
                        selected: selected,
                        selectedColor: Colors.green,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : Colors.black,
                        ),
                        onSelected: (_) => context.read<AnalysisBloc>().add(
                          ChangeYear(year: yr, type: type),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Container(
                color: Colors.green.withOpacity(0.2),
                child: Column(
                  children: [
                    _PeriodRow(
                      label: 'Период: начало',
                      value: _monthYear(result.periodStart),
                    ),
                    _PeriodRow(
                      label: 'Период: конец',
                      value: _monthYear(result.periodEnd),
                    ),
                  ],
                ),
              ),
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
              if (result.total > 0)
                SizedBox(
                  height: 200,
                  child: PieChart(
                    swapAnimationDuration: const Duration(seconds: 3),
                    PieChartData(
                      sections: result.data.asMap().entries.map((entry) {
                        final idx = entry.key;
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
                ),
              const SizedBox(height: 48),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: result.data.asMap().entries.map((entry) {
                    final c = entry.value;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: c.color,
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
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: result.data.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final c = result.data[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: c.color.withOpacity(0.2),
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
      },
    );
  }

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
