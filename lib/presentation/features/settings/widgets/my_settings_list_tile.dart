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

class SettingsSwitchListTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget title;
  final Color? activeColor;
  final Key? switchKey;

  const SettingsSwitchListTile({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
    this.activeColor,
    this.switchKey,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: title,
      trailing: Switch(
        key: switchKey,
        value: value,
        onChanged: onChanged,
        activeColor: activeColor,
      ),
      onTap: () => onChanged(!value),
    );
  }
}
