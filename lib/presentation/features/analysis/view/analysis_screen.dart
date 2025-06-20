import 'package:cashnetic/presentation/features/analysis/bloc/analysis_bloc.dart';
import 'package:cashnetic/presentation/features/analysis/bloc/analysis_event.dart';
import 'package:cashnetic/presentation/features/analysis/bloc/analysis_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/period_row.dart';
import '../widgets/analysis_pie_chart.dart';
import '../widgets/analysis_legend.dart';
import '../widgets/analysis_category_list.dart';
import 'package:flutter/rendering.dart';

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
        final selectedYears = state.selectedYears;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              type == AnalysisType.expense
                  ? 'Анализ расходов'
                  : 'Анализ доходов',
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: Colors.green,
            leading: const BackButton(color: Colors.white),
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.green.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Wrap(
                    spacing: 8,
                    children: state.availableYears.map((yr) {
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
                        onSelected: (val) {
                          final newYears = List<int>.from(selectedYears);
                          if (val) {
                            newYears.add(yr);
                          } else {
                            newYears.remove(yr);
                          }
                          if (newYears.isNotEmpty) {
                            context.read<AnalysisBloc>().add(
                              ChangeYears(
                                years: newYears.toSet().toList()..sort(),
                                type: type,
                              ),
                            );
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
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
              ),
              SliverToBoxAdapter(
                child: Container(
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
              ),
              SliverToBoxAdapter(child: SizedBox(height: 28)),
              if (result.total > 0)
                SliverToBoxAdapter(child: AnalysisPieChart(data: result.data)),
              SliverToBoxAdapter(child: SizedBox(height: 28)),
              SliverPersistentHeader(
                pinned: true,
                delegate: _LegendHeaderDelegate(
                  child: AnalysisLegend(data: result.data),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: AnalysisCategoryList(data: result.data),
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

// Делегат для закреплённой легенды
class _LegendHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _LegendHeaderDelegate({required this.child});
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Colors.green.withOpacity(0.1),
      child: SizedBox(height: maxExtent, child: child),
    );
  }

  @override
  double get maxExtent => 80;
  @override
  double get minExtent => 80;
  @override
  bool shouldRebuild(covariant _LegendHeaderDelegate oldDelegate) => false;
}
