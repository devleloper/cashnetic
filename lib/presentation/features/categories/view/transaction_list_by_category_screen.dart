import 'package:cashnetic/data/models/category/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashnetic/domain/entities/transaction.dart';
import '../bloc/categories_bloc.dart';
import '../bloc/categories_state.dart';
import '../bloc/categories_event.dart';
import '../../../presentation.dart';
import 'package:cashnetic/utils/category_utils.dart';
import 'package:cashnetic/data/mappers/transaction_mapper.dart';
import 'package:cashnetic/presentation/features/transaction_edit/view/transaction_edit_screen.dart';

class TransactionListByCategoryScreen extends StatelessWidget {
  final CategoryDTO category;
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
                  orElse: () => CategoryDTO(
                    id: 0,
                    name: '—',
                    emoji: '❓',
                    isIncome: false,
                    color: '#E0E0E0',
                  ),
                );
                return MyItemListTile(
                  transaction: t,
                  category: cat,
                  bgColor: colorFor(cat.name).withOpacity(0.2),
                  onTap: () async {
                    final model = TransactionDomainMapper.domainToModel(
                      t,
                      cat,
                      'Сбербанк', // TODO: получить реальное название аккаунта
                    );
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            TransactionEditScreen(transaction: model),
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
