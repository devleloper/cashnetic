import 'package:flutter/material.dart';
import 'package:cashnetic/domain/entities/transaction.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'package:cashnetic/utils/format_currency.dart';
import 'package:intl/intl.dart';

class MyItemListTile extends StatelessWidget {
  const MyItemListTile({
    super.key,
    required this.transaction,
    required this.category,
    required this.bgColor,
  });

  final Transaction transaction;
  final Category category;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    final formattedAmount = formatCurrency(transaction.amount.abs());
    final formattedDate = DateFormat(
      'dd.MM.yyyy',
    ).format(transaction.timestamp);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: bgColor,
        child: Text(category.emoji, style: const TextStyle(fontSize: 18)),
      ),
      title: Text(category.name),
      subtitle: transaction.comment != null && transaction.comment!.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.comment!),
                Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            )
          : Text(
              formattedDate,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
      trailing: Text(
        '$formattedAmount ₽',
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      onTap: () {
        // TODO: переход к экрану редактирования транзакции
      },
    );
  }
}
