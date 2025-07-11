import 'package:flutter/material.dart';

class AnalysisCategoryList extends StatelessWidget {
  final List<dynamic> data;
  const AnalysisCategoryList({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // If inside slivers — use Column
    return Column(
      children: List.generate(data.length, (i) {
        final c = data[i];
        return Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: c.color.withOpacity(0.2),
                child: Text(c.categoryIcon),
              ),
              title: Text(c.categoryTitle),
              subtitle: Text('${c.percent.toStringAsFixed(0)}%'),
              trailing: Text('${c.amount.toStringAsFixed(0)} ₽'),
            ),
            if (i < data.length - 1) const Divider(height: 1),
          ],
        );
      }),
    );
  }
}
