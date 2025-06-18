import 'package:cashnetic/data/models/category/category.dart';
import 'package:flutter/material.dart';

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
        backgroundColor: Color(
          int.parse(category.color.replaceFirst('#', '0xff')),
        ),
        child: Text(category.emoji, style: const TextStyle(fontSize: 18)),
      ),
      title: Text(category.name),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }
}
