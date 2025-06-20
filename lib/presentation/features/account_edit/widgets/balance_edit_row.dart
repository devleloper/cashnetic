import 'package:flutter/material.dart';

class BalanceEditRow extends StatelessWidget {
  final TextEditingController controller;
  const BalanceEditRow({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.account_balance_wallet_outlined),
          const SizedBox(width: 16),
          const Expanded(child: Text('Баланс')),
          SizedBox(
            width: 120,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.end,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                suffixText: '₽',
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}
