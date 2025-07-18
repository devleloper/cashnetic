import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../repositories/haptic_service.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final ThemeMode themeMode;
  final Color primaryColor;
  final bool soundsEnabled;
  final bool hapticsEnabled;
  final String? passcode;
  final bool syncEnabled;
  final String language;
  final bool biometryEnabled;
  final HapticStrength hapticStrength;

  const SettingsLoaded({
    required this.themeMode,
    required this.primaryColor,
    required this.soundsEnabled,
    required this.hapticsEnabled,
    this.passcode,
    required this.syncEnabled,
    required this.language,
    this.biometryEnabled = false,
    this.hapticStrength = HapticStrength.medium,
  });

  @override
  List<Object?> get props => [
    themeMode,
    primaryColor,
    soundsEnabled,
    hapticsEnabled,
    passcode,
    syncEnabled,
    language,
    biometryEnabled,
    hapticStrength,
  ];

  SettingsLoaded copyWith({
    ThemeMode? themeMode,
    Color? primaryColor,
    bool? soundsEnabled,
    bool? hapticsEnabled,
    String? passcode,
    bool? syncEnabled,
    String? language,
    bool? biometryEnabled,
    HapticStrength? hapticStrength,
  }) {
    return SettingsLoaded(
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
      soundsEnabled: soundsEnabled ?? this.soundsEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      passcode: passcode ?? this.passcode,
      syncEnabled: syncEnabled ?? this.syncEnabled,
      language: language ?? this.language,
      biometryEnabled: biometryEnabled ?? this.biometryEnabled,
      hapticStrength: hapticStrength ?? this.hapticStrength,
    );
  }
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}
