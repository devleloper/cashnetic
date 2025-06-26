import 'package:cashnetic/data/database.dart';
import 'package:cashnetic/data/models/category/category.dart';
import 'package:cashnetic/presentation/features/analysis/bloc/analysis_bloc.dart';
import 'package:cashnetic/presentation/features/analysis/bloc/analysis_event.dart';
import 'package:cashnetic/presentation/features/analysis/bloc/analysis_state.dart';
import 'package:cashnetic/presentation/features/categories/view/transaction_list_by_category_screen.dart';
import 'package:cashnetic/presentation/features/categories/widgets/category_list.dart';
import 'package:cashnetic/presentation/widgets/category_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/period_row.dart';
import '../widgets/analysis_pie_chart.dart';
import '../widgets/analysis_legend.dart';
import '../widgets/analysis_category_list.dart';
import 'package:flutter/rendering.dart';
import 'package:cashnetic/data/mappers/category_mapper.dart';
import 'package:cashnetic/domain/entities/category.dart' as domain;
import '../widgets/analysis_year_filter_chips.dart';
import '../widgets/analysis_period_selector.dart';
import '../widgets/analysis_total_summary.dart';
import '../widgets/analysis_category_sliver_list.dart';

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
        // Сортируем категории по дате последней транзакции
        final sortedData = List<CategoryChartData>.from(result.data)
          ..sort((a, b) {
            final ad = a.lastTransactionDate ?? DateTime(1970);
            final bd = b.lastTransactionDate ?? DateTime(1970);
            return bd.compareTo(ad);
          });
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
                  child: AnalysisYearFilterChips(
                    availableYears: state.availableYears,
                    selectedYears: selectedYears,
                    type: type,
                    onChanged: (newYears) {
                      context.read<AnalysisBloc>().add(
                        ChangeYears(years: newYears, type: type),
                      );
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  color: Colors.green.withOpacity(0.2),
                  child: AnalysisPeriodSelector(
                    periodStart: result.periodStart,
                    periodEnd: result.periodEnd,
                    type: type,
                    onChanged: (from, to) {
                      context.read<AnalysisBloc>().add(
                        ChangePeriod(from: from, to: to, type: type),
                      );
                    },
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
                  child: AnalysisTotalSummary(total: result.total),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 42)),
              if (result.total > 0 && result.data.isNotEmpty)
                SliverToBoxAdapter(child: AnalysisPieChart(data: result.data)),
              SliverToBoxAdapter(child: SizedBox(height: 28)),
              SliverPersistentHeader(
                pinned: true,
                delegate: _LegendHeaderDelegate(
                  child: AnalysisLegend(data: result.data),
                ),
              ),
              if (result.data.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'Нет данных для анализа',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                )
              else
                AnalysisCategorySliverList(sortedData: sortedData, type: type),
            ],
          ),
        );
      },
    );
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
      color: Colors.white,
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
