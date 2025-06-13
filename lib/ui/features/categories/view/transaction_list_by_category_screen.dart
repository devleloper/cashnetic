import 'package:cashnetic/models/category/category_model.dart';
import 'package:cashnetic/view_models/categories/categories_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../ui.dart';

class TransactionListByCategoryScreen extends StatelessWidget {
  final CategoryModel category;
  const TransactionListByCategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CategoriesViewModel>();
    final txns = vm.transactionsByCategory(category.id);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        title: Text(category.name),
      ),
      body: ListView.separated(
        itemCount: txns.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final t = txns[i];
          return MyItemListTile(e: t, bgColor: Colors.green.shade50);
        },
      ),
    );
  }
}
