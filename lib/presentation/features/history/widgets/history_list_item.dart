import 'package:flutter/material.dart';
import 'package:cashnetic/presentation/widgets/item_list_tile.dart';
import 'package:cashnetic/presentation/features/transaction_edit/view/transaction_edit_screen.dart';
import 'package:cashnetic/domain/entities/transaction.dart';
import 'package:cashnetic/domain/entities/category.dart';

class HistoryListItem extends StatelessWidget {
  final Transaction transaction;
  final Category category;
  final Color bgColor;
  final VoidCallback onEdited;
  const HistoryListItem({
    Key? key,
    required this.transaction,
    required this.category,
    required this.bgColor,
    required this.onEdited,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyItemListTile(
      transaction: transaction,
      category: category,
      bgColor: bgColor,
      onTap: () async {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => FractionallySizedBox(
            heightFactor: 1,
            child: TransactionEditScreen(transactionId: transaction.id),
          ),
        );
        onEdited();
      },
    );
  }
}
