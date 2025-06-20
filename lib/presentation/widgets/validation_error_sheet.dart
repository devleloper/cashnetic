import 'package:flutter/material.dart';

class ValidationErrorSheet extends StatelessWidget {
  final List<String> errors;
  final VoidCallback onClose;
  const ValidationErrorSheet({
    Key? key,
    required this.errors,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ошибки валидации:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...errors.map(
            (error) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(error)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onClose,
              child: const Text('Понятно'),
            ),
          ),
        ],
      ),
    );
  }
}
