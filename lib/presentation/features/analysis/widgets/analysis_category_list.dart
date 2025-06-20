import 'package:flutter/material.dart';

class AnalysisCategoryList extends StatelessWidget {
  final List<dynamic> data;
  const AnalysisCategoryList({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: data.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final c = data[i];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: c.color.withOpacity(0.2),
            child: Text(c.categoryIcon),
          ),
          title: Text(c.categoryTitle),
          subtitle: Text('${c.percent.toStringAsFixed(0)}%'),
          trailing: Text('${c.amount.toStringAsFixed(0)} ₽'),
        );
      },
    );
  }
}
