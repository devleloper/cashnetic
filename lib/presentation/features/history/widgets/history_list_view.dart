import 'package:cashnetic/generated/l10n.dart';
import 'package:cashnetic/presentation/widgets/category_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:cashnetic/domain/entities/transaction.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'package:cashnetic/presentation/features/history/widgets/history_list_item.dart';
import 'package:cashnetic/utils/category_utils.dart';
import 'package:cashnetic/presentation/theme/light_color_for.dart';

class HistoryListView extends StatelessWidget {
  final List<Transaction> transactions;
  final List<Category> categories;
  final bool isIncome;
  final VoidCallback onEdited;
  const HistoryListView({
    Key? key,
    required this.transactions,
    required this.categories,
    required this.isIncome,
    required this.onEdited,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Center(
        child: Text(
          isIncome
              ? S.of(context).noIncomeForTheLastMonth
              : S.of(context).noExpensesForTheLastMonth,
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, index) {
        final e = transactions[index];
        final cat = categories.firstWhere(
          (c) => c.id == e.categoryId,
          orElse: () => Category(
            id: 0,
            name: '—',
            emoji: '❓',
            isIncome: false,
            color: '#E0E0E0',
          ),
        );
        final bgColor = lightColorFor(cat.name);
        return HistoryListItem(
          transaction: e,
          category: cat,
          bgColor: bgColor,
          onEdited: onEdited,
        );
      },
    );
  }
}
