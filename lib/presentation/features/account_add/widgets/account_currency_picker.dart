import 'package:cashnetic/generated/l10n.dart';
import 'package:flutter/material.dart';

class AccountCurrencyPicker extends StatelessWidget {
  final String currency;
  final ValueChanged<String> onChanged;
  const AccountCurrencyPicker({
    super.key,
    required this.currency,
    required this.onChanged,
  });

  void _showCurrencyPicker(BuildContext context) async {
    final sel = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(S.of(context).russianRuble),
            onTap: () => Navigator.pop(context, '₽'),
          ),
          ListTile(
            title: Text(S.of(context).dollar),
            onTap: () => Navigator.pop(context, '\$'),
          ),
          ListTile(
            title: Text(S.of(context).euro),
            onTap: () => Navigator.pop(context, '€'),
          ),
          const Divider(),
          ListTile(
            title: Text(S.of(context).cancel),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
    if (sel != null && sel != currency) {
      onChanged(sel);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showCurrencyPicker(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const Icon(Icons.currency_exchange, color: Colors.green),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Currency', style: TextStyle(fontSize: 16)),
            ),
            Text(
              currency,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
