import 'package:flutter/material.dart';

class AccountBalanceField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const AccountBalanceField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Row(
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            color: Colors.green,
          ),
          const SizedBox(width: 16),
          const Expanded(child: Text('Баланс')),
          SizedBox(
            width: 100,
            child: TextFormField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.end,
              decoration: const InputDecoration(
                labelText: 'Баланс',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Введите число';
                final n = double.tryParse(val.replaceAll(',', '.'));
                if (n == null) return 'Только число';
                return null;
              },
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
