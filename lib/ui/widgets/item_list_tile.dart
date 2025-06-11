import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../features/transaction_edit/transaction_edit.dart';

class MyItemListTile extends StatelessWidget {
  const MyItemListTile({super.key, required this.e, required this.bgColor});

  final TransactionModel e;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TransactionEditScreen(transaction: e),
          ),
        );
      },
      leading: CircleAvatar(
        backgroundColor: bgColor,
        child: Text(e.categoryIcon, style: const TextStyle(fontSize: 18)),
      ),
      title: Text(e.categoryTitle),
      subtitle: e.comment != null ? Text(e.comment!) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${e.amount.toStringAsFixed(0)} ₽',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
