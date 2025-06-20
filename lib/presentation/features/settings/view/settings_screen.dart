import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
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
    return BlocProvider(
      create: (context) => SettingsBloc()..add(const LoadSettings()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Настройки')),
        body: BlocConsumer<SettingsBloc, SettingsState>(
          listener: (context, state) {
            if (state is SettingsError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is SettingsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is SettingsLoaded) {
              return ListView(
                children: [
                  SwitchListTile(
                    title: const Text('Тёмная тема'),
                    value: state.isDarkTheme,
                    onChanged: (_) {
                      context.read<SettingsBloc>().add(const ToggleDarkTheme());
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Основной цвет'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Implement color picker
                      context.read<SettingsBloc>().add(
                        const UpdatePrimaryColor(0xFF2196F3),
                      );
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Звуки'),
                    value: state.soundsEnabled,
                    onChanged: (_) {
                      context.read<SettingsBloc>().add(const ToggleSounds());
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Хаптики'),
                    value: state.hapticsEnabled,
                    onChanged: (_) {
                      context.read<SettingsBloc>().add(const ToggleHaptics());
                    },
                  ),
                  ListTile(
                    title: const Text('Код пароль'),
                    subtitle: Text(
                      state.passcode != null ? 'Установлен' : 'Не установлен',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Implement passcode setup
                      _showPasscodeDialog(context, state.passcode);
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Синхронизация'),
                    value: state.syncEnabled,
                    onChanged: (_) {
                      context.read<SettingsBloc>().add(const ToggleSync());
                    },
                  ),
                  ListTile(
                    title: const Text('Язык'),
                    subtitle: Text(
                      state.language == 'ru' ? 'Русский' : 'English',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Implement language selection
                      context.read<SettingsBloc>().add(
                        const UpdateLanguage('ru'),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  MySettingsListTile(
                    title: 'О программе',
                    onTap: () => _showAboutDialog(context),
                  ),
                ],
              );
            }

            if (state is SettingsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<SettingsBloc>().add(const LoadSettings());
                      },
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              );
            }

            return const Center(child: Text('Неизвестное состояние'));
          },
        ),
      ),
    );
  }

  void _showPasscodeDialog(BuildContext context, String? currentPasscode) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          currentPasscode != null ? 'Изменить пароль' : 'Установить пароль',
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Введите пароль',
            hintText: '4-6 цифр',
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              final passcode = controller.text.trim();
              if (passcode.isNotEmpty) {
                context.read<SettingsBloc>().add(UpdatePasscode(passcode));
              }
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}
