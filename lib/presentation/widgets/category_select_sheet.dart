import 'package:cashnetic/generated/l10n.dart';
import 'package:cashnetic/presentation/widgets/category_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'package:cashnetic/utils/category_utils.dart';
import 'package:cashnetic/presentation/theme/light_color_for.dart';

class CategorySelectSheet extends StatelessWidget {
  final List<Category> categories;
  final bool isIncome;
  final ValueChanged<Category> onSelect;
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
                    backgroundColor: lightColorFor(context, cat.name),
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
