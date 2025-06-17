import 'package:equatable/equatable.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final bool isDarkTheme;
  final int primaryColor;
  final bool soundsEnabled;
  final bool hapticsEnabled;
  final String? passcode;
  final bool syncEnabled;
  final String language;

  const SettingsLoaded({
    required this.isDarkTheme,
    required this.primaryColor,
    required this.soundsEnabled,
    required this.hapticsEnabled,
    this.passcode,
    required this.syncEnabled,
    required this.language,
  });

  @override
  List<Object?> get props => [
    isDarkTheme,
    primaryColor,
    soundsEnabled,
    hapticsEnabled,
    passcode,
    syncEnabled,
    language,
  ];

  SettingsLoaded copyWith({
    bool? isDarkTheme,
    int? primaryColor,
    bool? soundsEnabled,
    bool? hapticsEnabled,
    String? passcode,
    bool? syncEnabled,
    String? language,
  }) {
    return SettingsLoaded(
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
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
