import 'package:flutter/material.dart';

class PeriodRow extends StatelessWidget {
  final String label, value;
  const PeriodRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: textColor)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w500, color: textColor),
          ),
        ],
      ),
    );
  }
}
