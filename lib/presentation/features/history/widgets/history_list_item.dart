import 'package:flutter/material.dart';
import 'package:cashnetic/data/models/transaction_response/transaction_response.dart';
import 'package:cashnetic/data/models/category/category.dart';
import 'package:cashnetic/presentation/widgets/item_list_tile.dart';
import 'package:cashnetic/presentation/features/transaction_edit/view/transaction_edit_screen.dart';
import 'package:cashnetic/data/mappers/transaction_mapper.dart';
import 'package:cashnetic/data/mappers/category_mapper.dart';
import 'package:cashnetic/domain/entities/transaction.dart';
import 'package:cashnetic/domain/entities/category.dart';

class HistoryListItem extends StatelessWidget {
  final TransactionResponseDTO transaction;
  final CategoryDTO category;
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
    final txOrFailure = transaction.toDomain();
    final catOrFailure = category.toDomain();
    if (txOrFailure.isLeft() || catOrFailure.isLeft()) {
      return const SizedBox.shrink();
    }
    final Transaction tx = txOrFailure.getOrElse(() => throw Exception());
    final Category cat = catOrFailure.getOrElse(() => throw Exception());
    return MyItemListTile(
      transaction: tx,
      category: cat,
      bgColor: bgColor,
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TransactionEditScreen(transaction: transaction),
          ),
        );
        if (result == true) {
          onEdited();
        }
      },
    );
  }
}
