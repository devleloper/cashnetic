import 'package:cashnetic/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:cashnetic/domain/entities/account.dart';

class AccountSelectSheet extends StatelessWidget {
  final List<Account> accounts;
  final ValueChanged<Account> onSelect;
  final VoidCallback? onCreateAccount;
  const AccountSelectSheet({
    Key? key,
    required this.accounts,
    required this.onSelect,
    this.onCreateAccount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).selectAccount,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.black, weight: 60),
                onPressed: onCreateAccount,
                tooltip: S.of(context).createAccount,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              ...accounts.map(
                (account) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.withOpacity(0.2),
                    child: Text(
                      account.moneyDetails.currency,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(account.name),
                  onTap: () => onSelect(account),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.add),
                title: Text(S.of(context).createAccount),
                onTap: onCreateAccount,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
