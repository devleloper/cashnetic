import 'package:cashnetic/generated/l10n.dart';
import 'package:flutter/material.dart';

class HistoryTotalRow extends StatelessWidget {
  final double total;
  const HistoryTotalRow({Key? key, required this.total}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
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
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
