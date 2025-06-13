import 'package:auto_route/annotations.dart';
import 'package:cashnetic/ui/features/categories/widgets/category_list_tile.dart';
import 'package:cashnetic/view_models/categories/categories_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'transaction_list_by_category_screen.dart';

@RoutePage()
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CategoriesViewModel>();
    final all = vm.categories;
    final filtered = _search.isEmpty
        ? all
        : all
              .where(
                (c) => c.name.toLowerCase().contains(_search.toLowerCase()),
              )
              .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Категории')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Найти категорию',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final cat = filtered[i];
                return CategoryListTile(
                  category: cat,
                  onTap: () async {
                    final categoryId = cat.id;
                    await context
                        .read<CategoriesViewModel>()
                        .loadTransactionsFor(categoryId);

                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            TransactionListByCategoryScreen(category: cat),
                      ),
                    );

                    context.read<CategoriesViewModel>().loadTransactionsFor(
                      categoryId,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
