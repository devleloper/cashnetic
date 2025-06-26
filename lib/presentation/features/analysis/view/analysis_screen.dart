import 'package:cashnetic/data/database.dart';
import 'package:cashnetic/data/models/category/category.dart';
import 'package:cashnetic/presentation/features/analysis/bloc/analysis_bloc.dart';
import 'package:cashnetic/presentation/features/analysis/bloc/analysis_event.dart';
import 'package:cashnetic/presentation/features/analysis/bloc/analysis_state.dart';
import 'package:cashnetic/presentation/features/categories/view/transaction_list_by_category_screen.dart';
import 'package:cashnetic/presentation/features/categories/widgets/category_list.dart';
import 'package:cashnetic/presentation/features/categories/widgets/category_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/period_row.dart';
import '../widgets/analysis_pie_chart.dart';
import '../widgets/analysis_legend.dart';
import '../widgets/analysis_category_list.dart';
import 'package:flutter/rendering.dart';
import 'package:cashnetic/data/mappers/category_mapper.dart';
import 'package:cashnetic/domain/entities/category.dart' as domain;

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
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  color: Colors.green.withOpacity(0.2),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Период: начало',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shadowColor: Colors.transparent,
                              elevation: 0,
                              backgroundColor: Colors.green.withOpacity(0.8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 8,
                              ),
                            ),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: result.periodStart,
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                context.read<AnalysisBloc>().add(
                                  ChangePeriod(
                                    from: picked,
                                    to: result.periodEnd,
                                    type: type,
                                  ),
                                );
                              }
                            },
                            child: Text(
                              '${result.periodStart.day.toString().padLeft(2, '0')}.${result.periodStart.month.toString().padLeft(2, '0')}.${result.periodStart.year}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Период: конец',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shadowColor: Colors.transparent,
                              elevation: 0,
                              backgroundColor: Colors.green.withOpacity(0.8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 8,
                              ),
                            ),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: result.periodEnd,
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                context.read<AnalysisBloc>().add(
                                  ChangePeriod(
                                    from: result.periodStart,
                                    to: picked,
                                    type: type,
                                  ),
                                );
                              }
                            },
                            child: Text(
                              '${result.periodEnd.day.toString().padLeft(2, '0')}.${result.periodEnd.month.toString().padLeft(2, '0')}.${result.periodEnd.year}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
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
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, i) {
                    final cat = result.data[i];
                    final catDTO = CategoryDTO(
                      id: cat.id ?? 0,
                      name: cat.categoryTitle,
                      emoji: cat.categoryIcon,
                      isIncome: type == AnalysisType.income,
                      color: '#E0E0E0',
                    );
                    return CategoryListTile(
                      category: catDTO,
                      txCount: 0,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TransactionListByCategoryScreen(
                              category: catDTO.toDomain().getOrElse(
                                () => domain.Category(
                                  id: catDTO.id,
                                  name: catDTO.name,
                                  emoji: catDTO.emoji,
                                  isIncome: catDTO.isIncome,
                                  color: catDTO.color,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      amount: cat.amount,
                      percent: cat.percent,
                      showPercent: true,
                    );
                  }, childCount: result.data.length),
                ),
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
