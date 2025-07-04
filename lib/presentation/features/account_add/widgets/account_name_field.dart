import 'package:cashnetic/generated/l10n.dart';
import 'package:flutter/material.dart';

class AccountNameField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const AccountNameField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: S.of(context).accountName,
          border: OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
