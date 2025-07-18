import 'package:auto_route/auto_route.dart';
import 'package:cashnetic/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../theme/theme.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../widgets/my_settings_list_tile.dart';
import '../../pin/view/pin_screen.dart';
import '../../pin/repositories/pin_repository.dart';
import '../repositories/haptic_service.dart';

@RoutePage()
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _SettingsScreenBody();
  }
}

class _SettingsScreenBody extends StatelessWidget {
  _SettingsScreenBody({super.key});
  final GlobalKey switchKey = GlobalKey();

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(S.of(context).about),
        content: Text(
          S
              .of(context)
              .developerDevletBoltaevnversion100nnthankYouForUsingCashnetic,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _getHapticStrengthText(HapticStrength strength) {
    switch (strength) {
      case HapticStrength.off:
        return 'Off';
      case HapticStrength.light:
        return 'Light';
      case HapticStrength.medium:
        return 'Medium';
      case HapticStrength.heavy:
        return 'Heavy';
    }
  }

  void _showHapticStrengthDialog(BuildContext context, HapticStrength currentStrength) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Haptic Strength'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<HapticStrength>(
              title: const Text('Off'),
              value: HapticStrength.off,
              groupValue: currentStrength,
              onChanged: (value) async {
                if (value != null) {
                  // Воспроизводим хаптик перед изменением настройки
                  final hapticService = HapticService();
                  await hapticService.light();
                  
                  context.read<SettingsBloc>().add(UpdateHapticStrength(value));
                }
                Navigator.pop(context);
              },
            ),
            RadioListTile<HapticStrength>(
              title: const Text('Light'),
              value: HapticStrength.light,
              groupValue: currentStrength,
              onChanged: (value) async {
                if (value != null) {
                  // Воспроизводим легкий хаптик
                  final hapticService = HapticService();
                  await hapticService.light();
                  
                  context.read<SettingsBloc>().add(UpdateHapticStrength(value));
                }
                Navigator.pop(context);
              },
            ),
            RadioListTile<HapticStrength>(
              title: const Text('Medium'),
              value: HapticStrength.medium,
              groupValue: currentStrength,
              onChanged: (value) async {
                if (value != null) {
                  // Воспроизводим средний хаптик
                  final hapticService = HapticService();
                  await hapticService.medium();
                  
                  context.read<SettingsBloc>().add(UpdateHapticStrength(value));
                }
                Navigator.pop(context);
              },
            ),
            RadioListTile<HapticStrength>(
              title: const Text('Heavy'),
              value: HapticStrength.heavy,
              groupValue: currentStrength,
              onChanged: (value) async {
                if (value != null) {
                  // Воспроизводим сильный хаптик
                  final hapticService = HapticService();
                  await hapticService.heavy();
                  
                  context.read<SettingsBloc>().add(UpdateHapticStrength(value));
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var darkTheme = darkThemeData();
    var lightTheme = lightThemeData();
    return Scaffold(
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
                  title: Text('Системная тема'),
                  value: state.themeMode == ThemeMode.system,
                  onChanged: (useSystem) {
                    context.read<SettingsBloc>().add(
                      UpdateThemeMode(
                        useSystem ? ThemeMode.system : ThemeMode.light,
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text(S.of(context).primaryColor),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Implement color picker
                    context.read<SettingsBloc>().add(
                      const UpdatePrimaryColor(0xFF2196F3),
                    );
                  },
                ),
                SwitchListTile(
                  title: Text(S.of(context).sounds),
                  value: state.soundsEnabled,
                  onChanged: (_) {
                    context.read<SettingsBloc>().add(const ToggleSounds());
                  },
                ),
                SwitchListTile(
                  title: Text(S.of(context).haptics),
                  value: state.hapticsEnabled,
                  onChanged: (_) {
                    context.read<SettingsBloc>().add(const ToggleHaptics());
                  },
                ),
                ListTile(
                  title: Text('Haptic Strength'),
                  subtitle: Text(_getHapticStrengthText(state.hapticStrength)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showHapticStrengthDialog(context, state.hapticStrength);
                  },
                ),
                ListTile(
                  title: Text(S.of(context).passcode),
                  subtitle: FutureBuilder<String?>(
                    future: PinRepositoryImpl().getPin(),
                    builder: (context, snapshot) {
                      final pin = snapshot.data;
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox.shrink();
                      }
                      if (pin != null && pin.isNotEmpty) {
                        return Text('Edit');
                      } else {
                        return Text(S.of(context).notSet);
                      }
                    },
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final pin = await PinRepositoryImpl().getPin();
                    final mode = (pin != null && pin.isNotEmpty)
                        ? PinScreenMode.edit
                        : PinScreenMode.set;
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PinScreen(mode: mode),
                      ),
                    );
                    if (result == true) {
                      // setState не нужен, BlocConsumer обновит
                    }
                  },
                ),
                SwitchListTile(
                  title: Text('Biometrics'),
                  value: state.biometryEnabled,
                  onChanged: (_) {
                    context.read<SettingsBloc>().add(const ToggleBiometry());
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text(S.of(context).sync),
                  value: state.syncEnabled,
                  onChanged: (_) {
                    context.read<SettingsBloc>().add(const ToggleSync());
                  },
                ),
                ListTile(
                  title: Text(S.of(context).language),
                  subtitle: Text(
                    state.language == 'ru'
                        ? S.of(context).russian
                        : state.language == 'de'
                        ? 'Deutsch'
                        : S.of(context).english,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (ctx) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                S.of(context).selectLanguage,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ListTile(
                              title: const Text('English'),
                              onTap: () {
                                context.read<SettingsBloc>().add(
                                  const UpdateLanguage('en'),
                                );
                                Navigator.pop(ctx);
                              },
                            ),
                            ListTile(
                              title: const Text('Русский'),
                              onTap: () {
                                context.read<SettingsBloc>().add(
                                  const UpdateLanguage('ru'),
                                );
                                Navigator.pop(ctx);
                              },
                            ),
                            ListTile(
                              title: const Text('Deutsch'),
                              onTap: () {
                                context.read<SettingsBloc>().add(
                                  const UpdateLanguage('de'),
                                );
                                Navigator.pop(ctx);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const Divider(height: 1),
                MySettingsListTile(
                  title: S.of(context).about,
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
                    child: Text(S.of(context).retry),
                  ),
                ],
              ),
            );
          }

          return Center(child: Text(S.of(context).unknownState));
        },
      ),
    );
  }
}
