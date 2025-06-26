import 'package:flutter/material.dart';
import 'package:cashnetic/data/models/category/category.dart';
import 'package:cashnetic/presentation/widgets/category_list_tile.dart';
import 'package:cashnetic/presentation/features/categories/view/transaction_list_by_category_screen.dart';
import 'package:cashnetic/data/mappers/category_mapper.dart';
import 'package:cashnetic/domain/entities/category.dart' as domain;
import '../bloc/analysis_event.dart';
import '../bloc/analysis_state.dart';

class AnalysisCategorySliverList extends StatelessWidget {
  final List<CategoryChartData> sortedData;
  final AnalysisType type;
  const AnalysisCategorySliverList({
    super.key,
    required this.sortedData,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, i) {
        final cat = sortedData[i];
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
      }, childCount: sortedData.length),
    );
  }
}
