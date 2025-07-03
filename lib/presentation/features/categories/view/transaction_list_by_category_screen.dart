import 'package:cashnetic/presentation/widgets/category_list_tile.dart'
    show lightColorFor;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/categories_bloc.dart';
import '../bloc/categories_state.dart';
import '../bloc/categories_event.dart';
import '../../../presentation.dart';
import 'package:cashnetic/utils/category_utils.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'package:cashnetic/presentation/theme/light_color_for.dart';

class TransactionListByCategoryScreen extends StatelessWidget {
  final Category category;
  const TransactionListByCategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    // Запросим категории, если нужно
    context.read<CategoriesBloc>().add(LoadCategories());
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        title: Text(category.name),
      ),
      body: BlocBuilder<CategoriesBloc, CategoriesState>(
        builder: (context, state) {
          if (state is CategoriesLoaded) {
            final txns = state.txByCategory[category.id] ?? [];
            final categories = state.categories;
            return ListView.separated(
              itemCount: txns.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final t = txns[i];
                final cat = categories.firstWhere(
                  (c) => c.id == t.categoryId,
                  orElse: () => Category(
                    id: 0,
                    name: '—',
                    emoji: '❓',
                    isIncome: false,
                    color: '#E0E0E0',
                  ),
                );
                return MyItemListTile(
                  transaction: t,
                  category: Category(
                    id: cat.id,
                    name: cat.name,
                    emoji: cat.emoji,
                    isIncome: cat.isIncome,
                    color: cat.color,
                  ),
                  bgColor: lightColorFor(cat.name),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            TransactionEditScreen(transactionId: t.id),
                      ),
                    );
                    // После возврата можно обновить список транзакций по категории
                    context.read<CategoriesBloc>().add(
                      LoadTransactionsForCategory(category.id),
                    );
                  },
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
