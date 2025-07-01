import 'package:cashnetic/data/models/category/category.dart';
import 'package:cashnetic/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:cashnetic/utils/category_utils.dart';

class CategoryListTile extends StatelessWidget {
  final CategoryDTO category;
  final VoidCallback onTap;
  final int txCount;
  final double? amount;
  final double? percent;
  final bool showPercent;

  const CategoryListTile({
    super.key,
    required this.category,
    required this.onTap,
    this.txCount = 0,
    this.amount,
    this.percent,
    this.showPercent = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: colorFor(category.name).withOpacity(0.2),
        child: Text(category.emoji, style: const TextStyle(fontSize: 18)),
      ),
      title: Text(category.name),
      subtitle: showPercent
          ? Row(
              children: [
                if (percent != null)
                  Text(
                    '${percent!.toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.grey),
                  ),
                if (amount != null) ...[
                  if (percent != null) const SizedBox(width: 8),
                  Text(
                    '${amount!.toStringAsFixed(0)} ₽',
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ],
            )
          : (txCount > 0
                ? Text(S.of(context).transactionsTxcount(txCount))
                : null),
      trailing: showPercent
          ? null
          : const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }
}
