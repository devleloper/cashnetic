import 'package:flutter/material.dart';

class MySettingsListTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const MySettingsListTile({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(title),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }
}
