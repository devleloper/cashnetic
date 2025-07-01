import 'package:cashnetic/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:cashnetic/data/models/category/category.dart';
import 'package:cashnetic/utils/category_utils.dart';

class CategorySelectSheet extends StatelessWidget {
  final List<CategoryDTO> categories;
  final bool isIncome;
  final ValueChanged<CategoryDTO> onSelect;
  final VoidCallback onCreateCategory;
  const CategorySelectSheet({
    Key? key,
    required this.categories,
    required this.isIncome,
    required this.onSelect,
    required this.onCreateCategory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filteredCategories = categories
        .where((c) => c.isIncome == isIncome)
        .toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).selectCategory,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.black, weight: 60),
                onPressed: onCreateCategory,
                tooltip: S.of(context).createCategory,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              ...filteredCategories.map(
                (cat) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorFor(cat.name).withOpacity(0.2),
                    child: Text(
                      cat.emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  title: Text(cat.name),
                  onTap: () => onSelect(cat),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.add),
                title: Text(S.of(context).createCategory),
                onTap: onCreateCategory,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
