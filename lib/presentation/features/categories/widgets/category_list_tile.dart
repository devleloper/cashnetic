import 'package:cashnetic/data/models/category/category.dart';
import 'package:flutter/material.dart';
import 'package:cashnetic/utils/category_utils.dart';

class CategoryListTile extends StatelessWidget {
  final CategoryDTO category;
  final VoidCallback onTap;

  const CategoryListTile({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: colorFor(category.name).withOpacity(0.2),
        child: Text(category.emoji, style: const TextStyle(fontSize: 18)),
      ),
      title: Text(category.name),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }
}
