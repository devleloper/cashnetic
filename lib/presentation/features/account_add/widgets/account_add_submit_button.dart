import 'package:cashnetic/generated/l10n.dart';
import 'package:flutter/material.dart';

class AccountAddSubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  const AccountAddSubmitButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
          onPressed: onPressed,
          child: Text(S.of(context).create),
        ),
      ),
    );
  }
}
