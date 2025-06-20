import 'package:flutter/material.dart';

class AmountInputDialog extends StatelessWidget {
  final String currentAmount;
  final ValueChanged<String> onSubmit;
  const AmountInputDialog({
    Key? key,
    required this.currentAmount,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: currentAmount);
    return AlertDialog(
      title: const Text('Введите сумму'),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        autofocus: true,
        decoration: const InputDecoration(hintText: '0.00'),
      ),
      actions: [
        TextButton(
          onPressed: () {
            onSubmit(controller.text);
            Navigator.pop(context);
          },
          child: const Text('ОК'),
        ),
      ],
    );
  }
}
