import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cashnetic/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../theme/theme.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../widgets/my_settings_list_tile.dart';

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
                ThemeSwitcher(
                  clipper: ThemeSwitcherCircleClipper(),
                  builder: (context) {
                    return SettingsSwitchListTile(
                      switchKey: switchKey,
                      title: Text(S.of(context).darkTheme),
                      value:
                          ThemeModelInheritedNotifier.of(
                            context,
                          ).theme.brightness ==
                          Brightness.dark,
                      onChanged: (isDark) {
                        final theme = isDark ? darkTheme : lightTheme;
                        final renderBox =
                            switchKey.currentContext?.findRenderObject()
                                as RenderBox?;
                        final offset = renderBox != null
                            ? renderBox.localToGlobal(
                                Offset(
                                  renderBox.size.width,
                                  renderBox.size.height / 2,
                                ),
                              )
                            : Offset.zero;
                        ThemeSwitcher.of(
                          context,
                        ).changeTheme(theme: theme, offset: offset);
                        final newMode = isDark
                            ? ThemeMode.dark
                            : ThemeMode.light;
                        context.read<SettingsBloc>().add(
                          UpdateThemeMode(newMode),
                        );
                      },
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
                  title: Text(S.of(context).passcode),
                  subtitle: Text(
                    state.passcode != null
                        ? S.of(context).set
                        : S.of(context).notSet,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Implement passcode setup
                    _showPasscodeDialog(context, state.passcode);
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

  void _showPasscodeDialog(BuildContext context, String? currentPasscode) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          currentPasscode != null
              ? S.of(context).changePasscode
              : S.of(context).setPasscode,
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: S.of(context).enterPasscode,
            hintText: S.of(context).digits,
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              final passcode = controller.text.trim();
              if (passcode.isNotEmpty) {
                context.read<SettingsBloc>().add(UpdatePasscode(passcode));
              }
              Navigator.pop(context);
            },
            child: Text(S.of(context).save),
          ),
        ],
      ),
    );
  }
}
