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
      itemCount: categories.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final cat = categories[i];
        final txCount = txByCategory[cat.id]?.length ?? 0;
        final amount = amounts != null && i < amounts!.length
            ? amounts![i]
            : null;
        final percent = percents != null && i < percents!.length
            ? percents![i]
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
