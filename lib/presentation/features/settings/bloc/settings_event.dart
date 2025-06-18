import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

class ToggleDarkTheme extends SettingsEvent {
  const ToggleDarkTheme();
}

class UpdatePrimaryColor extends SettingsEvent {
  final int colorValue;

  const UpdatePrimaryColor(this.colorValue);

  @override
  List<Object?> get props => [colorValue];
}

class ToggleSounds extends SettingsEvent {
  const ToggleSounds();
}

class ToggleHaptics extends SettingsEvent {
  const ToggleHaptics();
}

class UpdatePasscode extends SettingsEvent {
  final String? passcode;

  const UpdatePasscode(this.passcode);

  @override
  List<Object?> get props => [passcode];
}

class ToggleSync extends SettingsEvent {
  const ToggleSync();
}

class UpdateLanguage extends SettingsEvent {
  final String language;

  const UpdateLanguage(this.language);

  @override
  List<Object?> get props => [language];
}
