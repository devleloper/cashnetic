import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings_event.dart';
import 'settings_state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:cashnetic/di/di.dart';
import '../repositories/settings_repository.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository settingsRepository = getIt<SettingsRepository>();

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
      final themeMode = await settingsRepository.loadThemeMode();
      final primaryColor = await settingsRepository.loadPrimaryColor();
      final soundsEnabled = await settingsRepository.loadSoundsEnabled();
      final hapticsEnabled = await settingsRepository.loadHapticsEnabled();
      final passcode = await settingsRepository.loadPasscode();
      final syncEnabled = await settingsRepository.loadSyncEnabled();
      final language = await settingsRepository.loadLanguage();
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
        await settingsRepository.saveThemeMode(event.themeMode);
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
        await settingsRepository.savePrimaryColor(event.colorValue);
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
        await settingsRepository.saveSoundsEnabled(newSoundsEnabled);
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
        await settingsRepository.saveHapticsEnabled(newHapticsEnabled);
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
        await settingsRepository.savePasscode(event.passcode);
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
        await settingsRepository.saveSyncEnabled(newSyncEnabled);
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
        await settingsRepository.saveLanguage(event.language);
        emit(currentState.copyWith(language: event.language));
      } catch (e) {
        emit(SettingsError('Failed to save language setting: $e'));
      }
    }
  }
}
