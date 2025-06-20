import 'package:flutter/material.dart';
import 'package:cashnetic/domain/entities/transaction.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'package:cashnetic/data/models/category/category.dart';
import 'package:cashnetic/data/models/account_brief/account_brief.dart';
import 'package:cashnetic/data/models/transaction_response/transaction_response.dart';
import 'package:cashnetic/presentation/features/history/widgets/history_list_item.dart';
import 'package:cashnetic/utils/category_utils.dart';

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
              ? 'Нет доходов за последний месяц'
              : 'Нет расходов за последний месяц',
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
        final bgColor = colorFor(cat.name).withOpacity(0.2);
        return HistoryListItem(
          transaction: TransactionResponseDTO(
            id: e.id,
            account: AccountBriefDTO(
              id: 1,
              name: 'Основной счёт',
              balance: '0',
              currency: '₽',
            ),
            category: CategoryDTO(
              id: cat.id,
              name: cat.name,
              emoji: cat.emoji,
              isIncome: cat.isIncome,
              color: cat.color,
            ),
            amount: e.amount.toString(),
            transactionDate: e.timestamp.toIso8601String(),
            comment: e.comment,
            createdAt: e.timeInterval.createdAt.toIso8601String(),
            updatedAt: e.timeInterval.updatedAt.toIso8601String(),
          ),
          category: CategoryDTO(
            id: cat.id,
            name: cat.name,
            emoji: cat.emoji,
            isIncome: cat.isIncome,
            color: cat.color,
          ),
          bgColor: bgColor,
          onEdited: onEdited,
        );
      },
    );
  }
}
