import 'package:cashnetic/generated/l10n.dart';
import 'package:flutter/material.dart';

class TransactionsTotalRow extends StatelessWidget {
  final double total;
  const TransactionsTotalRow({Key? key, required this.total}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green.withOpacity(0.2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            S.of(context).total,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            '${total.toStringAsFixed(0)} ₽',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
