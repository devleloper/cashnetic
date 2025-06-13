import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../widgets/my_settings_list_tile.dart';

@RoutePage()
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('О программе'),
        content: const Text(
          'Разработчик: Devlet Boltaev\nВерсия: 1.0.0\n\nСпасибо за использование Cashnetic!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ОК'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Тёмная тема'),
            value: false,
            onChanged: (_) {},
          ),
          const Divider(height: 1),
          MySettingsListTile(title: 'Основной цвет', onTap: () {}),
          MySettingsListTile(title: 'Звуки', onTap: () {}),
          MySettingsListTile(title: 'Хаптики', onTap: () {}),
          MySettingsListTile(title: 'Код пароль', onTap: () {}),
          MySettingsListTile(title: 'Синхронизация', onTap: () {}),
          MySettingsListTile(title: 'Язык', onTap: () {}),
          MySettingsListTile(
            title: 'О программе',
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }
}
