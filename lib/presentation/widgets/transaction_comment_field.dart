import 'package:cashnetic/generated/l10n.dart';
import 'package:flutter/material.dart';

class TransactionCommentField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onChanged;
  const TransactionCommentField({
    Key? key,
    required this.controller,
    required this.enabled,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: S.of(context).comment,
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      maxLines: 3,
      enabled: enabled,
      controller: controller,
      onChanged: onChanged,
    );
  }
}
