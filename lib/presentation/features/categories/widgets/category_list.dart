import 'package:flutter/material.dart';
import 'category_list_tile.dart';
import 'package:cashnetic/data/models/category/category.dart';

class CategoryList extends StatelessWidget {
  final List<CategoryDTO> categories;
  final Map<int, List<dynamic>> txByCategory;
  final Function(CategoryDTO) onCategoryTap;
  const CategoryList({
    super.key,
    required this.categories,
    required this.txByCategory,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: categories.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final cat = categories[i];
        final txCount = txByCategory[cat.id]?.length ?? 0;
        return CategoryListTile(
          category: cat,
          txCount: txCount,
          onTap: () => onCategoryTap(cat),
        );
      },
    );
  }
}
