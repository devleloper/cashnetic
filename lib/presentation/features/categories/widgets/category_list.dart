import 'package:flutter/material.dart';
import '../../../widgets/category_list_tile.dart';
import 'package:cashnetic/domain/entities/category.dart';

class CategoryList extends StatelessWidget {
  final List<Category> categories;
  final Map<int, List<dynamic>> txByCategory;
  final Function(Category) onCategoryTap;
  final List<double>? amounts;
  final List<double>? percents;
  final bool showPercent;
  const CategoryList({
    super.key,
    required this.categories,
    required this.txByCategory,
    required this.onCategoryTap,
    this.amounts,
    this.percents,
    this.showPercent = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: categories.length + 1, // +1 для пустого элемента
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        if (i == 0) {
          // Первый элемент — отступ
          return const SizedBox(height: 94);
        }
        final cat = categories[i - 1];
        final txCount = txByCategory[cat.id]?.length ?? 0;
        final amount = amounts != null && i - 1 < amounts!.length
            ? amounts![i - 1]
            : null;
        final percent = percents != null && i - 1 < percents!.length
            ? percents![i - 1]
            : null;
        return CategoryListTile(
          category: cat,
          txCount: txCount,
          onTap: () => onCategoryTap(cat),
          amount: amount,
          percent: percent,
          showPercent: showPercent,
        );
      },
    );
  }
}
