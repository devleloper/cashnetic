import 'package:cashnetic/presentation/features/analysis/bloc/analysis_bloc.dart';
import 'package:cashnetic/presentation/features/analysis/bloc/analysis_event.dart';
import 'package:cashnetic/presentation/features/analysis/bloc/analysis_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/period_row.dart';
import '../widgets/analysis_pie_chart.dart';
import '../widgets/analysis_legend.dart';
import '../widgets/analysis_category_list.dart';

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
                    PeriodRow(
                      label: 'Период: начало',
                      value: _monthYear(result.periodStart),
                    ),
                    PeriodRow(
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
              if (result.total > 0) AnalysisPieChart(data: result.data),
              const SizedBox(height: 48),
              AnalysisLegend(data: result.data),
              const SizedBox(height: 16),
              Expanded(child: AnalysisCategoryList(data: result.data)),
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
