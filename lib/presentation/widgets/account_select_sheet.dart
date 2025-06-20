import 'package:flutter/material.dart';
import 'package:cashnetic/domain/entities/account.dart';

class AccountSelectSheet extends StatelessWidget {
  final List<Account> accounts;
  final ValueChanged<Account> onSelect;
  const AccountSelectSheet({
    Key? key,
    required this.accounts,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: const Text(
            'Выберите счёт',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              ...accounts.map(
                (account) => ListTile(
                  title: Text(account.name),
                  subtitle: Text(account.moneyDetails?.currency ?? ''),
                  onTap: () => onSelect(account),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
