import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final ThemeMode themeMode;
  final int primaryColor;
  final bool soundsEnabled;
  final bool hapticsEnabled;
  final String? passcode;
  final bool syncEnabled;
  final String language;

  const SettingsLoaded({
    required this.themeMode,
    required this.primaryColor,
    required this.soundsEnabled,
    required this.hapticsEnabled,
    this.passcode,
    required this.syncEnabled,
    required this.language,
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
  ];

  SettingsLoaded copyWith({
    ThemeMode? themeMode,
    int? primaryColor,
    bool? soundsEnabled,
    bool? hapticsEnabled,
    String? passcode,
    bool? syncEnabled,
    String? language,
  }) {
    return SettingsLoaded(
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
      soundsEnabled: soundsEnabled ?? this.soundsEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      passcode: passcode ?? this.passcode,
      syncEnabled: syncEnabled ?? this.syncEnabled,
      language: language ?? this.language,
    );
  }
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}
