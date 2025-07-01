import 'package:cashnetic/generated/l10n.dart';
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
          Expanded(child: Text(S.of(context).balance)),
          SizedBox(
            width: 100,
            child: TextFormField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.end,
              decoration: InputDecoration(
                labelText: S.of(context).balance,
                border: OutlineInputBorder(),
                isDense: true,
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return S.of(context).enterANumber;
                }
                final n = double.tryParse(val.replaceAll(',', '.'));
                if (n == null) return S.of(context).onlyANumber;
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
