import 'package:flutter/material.dart';

class AnalysisTotalSummary extends StatelessWidget {
  final double total;
  const AnalysisTotalSummary({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Всего',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Text(
          '${total.toStringAsFixed(0)} ₽',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
