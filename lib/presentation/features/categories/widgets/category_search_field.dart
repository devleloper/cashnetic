import 'package:flutter/material.dart';

class CategorySearchField extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const CategorySearchField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Найти категорию',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
        ),
        onChanged: onChanged,
        controller: TextEditingController(text: value),
      ),
    );
  }
}
