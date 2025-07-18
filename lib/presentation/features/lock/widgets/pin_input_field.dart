import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class PinInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final void Function(String)? onSubmitted;
  const PinInputField({
    Key? key,
    required this.controller,
    this.errorText,
    this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
        fontSize: 20,
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(12),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Pinput(
          controller: controller,
          length: 4,
          obscureText: true,
          defaultPinTheme: defaultPinTheme,
          errorText: errorText,
          onCompleted: onSubmitted,
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              errorText!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }
}
