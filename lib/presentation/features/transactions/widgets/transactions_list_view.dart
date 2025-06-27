import 'package:flutter/material.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'package:cashnetic/domain/entities/transaction.dart';
import 'package:cashnetic/presentation/widgets/item_list_tile.dart';
import 'package:cashnetic/utils/category_utils.dart';

class TransactionsListView extends StatelessWidget {
  final List<Transaction> transactions;
  final List<Category> categories;
  final bool isIncome;
  final void Function(Transaction, Category) onTap;
  const TransactionsListView({
    Key? key,
    required this.transactions,
    required this.categories,
    required this.isIncome,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Center(
        child: Text(
          isIncome ? 'Нет доходов за сегодня' : 'Нет расходов за сегодня',
        ),
      );
    }
    final sorted = List<Transaction>.from(transactions)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return ListView.separated(
      itemCount: sorted.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final t = sorted[index];
        final cat = categories.firstWhere(
          (c) => c.id == t.categoryId,
          orElse: () => Category(
            id: 0,
            name: isIncome ? 'Доход' : 'Расход',
            emoji: isIncome ? '💰' : '💸',
            isIncome: isIncome,
            color: '#E0E0E0',
          ),
        );
        return MyItemListTile(
          transaction: t,
          category: cat,
          bgColor: colorFor(cat.name).withOpacity(0.2),
          onTap: () => onTap(t, cat),
        );
      },
    );
  }
}
