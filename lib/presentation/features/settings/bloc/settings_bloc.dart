import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_event.dart';
import 'settings_state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:cashnetic/data/repositories/theme_repository.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  static const String _primaryColorKey = 'primary_color';
  static const String _soundsKey = 'sounds_enabled';
  static const String _hapticsKey = 'haptics_enabled';
  static const String _passcodeKey = 'passcode';
  static const String _syncKey = 'sync_enabled';
  static const String _languageKey = 'language';

  final ThemeRepository _themeRepository = ThemeRepository();

  SettingsBloc() : super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateThemeMode>(_onUpdateThemeMode);
    on<UpdatePrimaryColor>(_onUpdatePrimaryColor);
    on<ToggleSounds>(_onToggleSounds);
    on<ToggleHaptics>(_onToggleHaptics);
    on<UpdatePasscode>(_onUpdatePasscode);
    on<ToggleSync>(_onToggleSync);
    on<UpdateLanguage>(_onUpdateLanguage);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeString = await _themeRepository.loadThemeMode();
      ThemeMode themeMode;
      if (themeString == 'light')
        themeMode = ThemeMode.light;
      else if (themeString == 'dark')
        themeMode = ThemeMode.dark;
      else
        themeMode = ThemeMode.system;

      final primaryColor = prefs.getInt(_primaryColorKey) ?? 0xFF2196F3;
      final soundsEnabled = prefs.getBool(_soundsKey) ?? true;
      final hapticsEnabled = prefs.getBool(_hapticsKey) ?? true;
      final passcode = prefs.getString(_passcodeKey);
      final syncEnabled = prefs.getBool(_syncKey) ?? false;
      String? language = prefs.getString(_languageKey);

      if (language == null) {
        final systemLocale =
            WidgetsBinding.instance.platformDispatcher.locale.languageCode;
        if (["en", "ru", "de"].contains(systemLocale)) {
          language = systemLocale;
        } else {
          language = "en";
        }
        await prefs.setString(_languageKey, language);
      }

      emit(
        SettingsLoaded(
          themeMode: themeMode,
          primaryColor: primaryColor,
          soundsEnabled: soundsEnabled,
          hapticsEnabled: hapticsEnabled,
          passcode: passcode,
          syncEnabled: syncEnabled,
          language: language,
        ),
      );
    } catch (e) {
      emit(SettingsError('Failed to load settings: $e'));
    }
  }

  Future<void> _onUpdateThemeMode(
    UpdateThemeMode event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      try {
        await _themeRepository.saveThemeMode(event.themeMode.name);
        emit(currentState.copyWith(themeMode: event.themeMode));
      } catch (e) {
        emit(SettingsError('Failed to save theme mode: $e'));
      }
    }
  }

  Future<void> _onUpdatePrimaryColor(
    UpdatePrimaryColor event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_primaryColorKey, event.colorValue);

        emit(currentState.copyWith(primaryColor: event.colorValue));
      } catch (e) {
        emit(SettingsError('Failed to save primary color: $e'));
      }
    }
  }

  Future<void> _onToggleSounds(
    ToggleSounds event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final newSoundsEnabled = !currentState.soundsEnabled;

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_soundsKey, newSoundsEnabled);

        emit(currentState.copyWith(soundsEnabled: newSoundsEnabled));
      } catch (e) {
        emit(SettingsError('Failed to save sounds setting: $e'));
      }
    }
  }

  Future<void> _onToggleHaptics(
    ToggleHaptics event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final newHapticsEnabled = !currentState.hapticsEnabled;

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_hapticsKey, newHapticsEnabled);

        emit(currentState.copyWith(hapticsEnabled: newHapticsEnabled));
      } catch (e) {
        emit(SettingsError('Failed to save haptics setting: $e'));
      }
    }
  }

  Future<void> _onUpdatePasscode(
    UpdatePasscode event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;

      try {
        final prefs = await SharedPreferences.getInstance();
        if (event.passcode != null) {
          await prefs.setString(_passcodeKey, event.passcode!);
        } else {
          await prefs.remove(_passcodeKey);
        }

        emit(currentState.copyWith(passcode: event.passcode));
      } catch (e) {
        emit(SettingsError('Failed to save passcode: $e'));
      }
    }
  }

  Future<void> _onToggleSync(
    ToggleSync event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final newSyncEnabled = !currentState.syncEnabled;

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_syncKey, newSyncEnabled);

        emit(currentState.copyWith(syncEnabled: newSyncEnabled));
      } catch (e) {
        emit(SettingsError('Failed to save sync setting: $e'));
      }
    }
  }

  Future<void> _onUpdateLanguage(
    UpdateLanguage event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_languageKey, event.language);
        emit(currentState.copyWith(language: event.language));
      } catch (e) {
        emit(SettingsError('Failed to save language setting: $e'));
      }
    }
  }
}
