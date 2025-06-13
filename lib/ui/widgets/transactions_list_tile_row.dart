import 'package:flutter/material.dart';

class MyListTileRow extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onTap;

  const MyListTileRow({
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(title),
          trailing: Text(value),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }
}
