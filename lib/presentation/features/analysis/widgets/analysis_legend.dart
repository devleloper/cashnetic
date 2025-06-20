import 'package:flutter/material.dart';

class AnalysisLegend extends StatelessWidget {
  final List<dynamic> data;
  const AnalysisLegend({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 12,
        runSpacing: 6,
        children: data.asMap().entries.map((entry) {
          final c = entry.value;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: c.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text('${c.categoryTitle} (${c.percent.toStringAsFixed(0)}%)'),
            ],
          );
        }).toList(),
      ),
    );
  }
}
