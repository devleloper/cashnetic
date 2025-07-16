import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

// class ToggleDarkTheme extends SettingsEvent {
//   const ToggleDarkTheme();
// }

class UpdateThemeMode extends SettingsEvent {
  final ThemeMode themeMode;
  const UpdateThemeMode(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
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

class SetPin extends SettingsEvent {
  final String pin;
  const SetPin(this.pin);
  @override
  List<Object?> get props => [pin];
}

class CheckPin extends SettingsEvent {
  final String pin;
  const CheckPin(this.pin);
  @override
  List<Object?> get props => [pin];
}

class DeletePin extends SettingsEvent {
  const DeletePin();
}

class AuthenticateBiometry extends SettingsEvent {
  final String reason;
  const AuthenticateBiometry({this.reason = 'Authenticate to access'});
  @override
  List<Object?> get props => [reason];
}

class ToggleBiometry extends SettingsEvent {
  const ToggleBiometry();
}
