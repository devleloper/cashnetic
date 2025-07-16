import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      obscureText: true,
      maxLength: 4,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        errorText: errorText,
        counterText: '',
      ),
      onSubmitted: onSubmitted,
    );
  }
}
