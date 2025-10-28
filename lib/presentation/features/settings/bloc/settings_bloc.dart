import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings_event.dart';
import 'settings_state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cashnetic/di/di.dart';
import '../repositories/settings_repository.dart';
import '../services/pin_service.dart';
import '../services/biometry_service.dart';
import '../services/haptic_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository settingsRepository = getIt<SettingsRepository>();
  final PinService pinService = PinService();
  final BiometryService biometryService = BiometryService();
  final HapticService hapticService = HapticService();

  static const String _biometryKey = 'biometry_enabled';

  Color _limitColorBrightness(Color color) {
    // Возвращаем цвет без изменений, так как используем стандартные Flutter цвета
    return color;
  }

  void _updateSystemNavigationColor(Color color) {
    SystemUiOverlayStyle overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: color,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: color,
    );
    SystemChrome.setSystemUIOverlayStyle(overlayStyle);
  }

  SettingsBloc() : super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateThemeMode>(_onUpdateThemeMode);
    on<UpdatePrimaryColor>(_onUpdatePrimaryColor);
    on<ToggleSounds>(_onToggleSounds);

    on<UpdatePasscode>(_onUpdatePasscode);
    on<ToggleSync>(_onToggleSync);
    on<UpdateLanguage>(_onUpdateLanguage);
    on<SetPin>(_onSetPin);
    on<CheckPin>(_onCheckPin);
    on<DeletePin>(_onDeletePin);
    on<AuthenticateBiometry>(_onAuthenticateBiometry);
    on<ToggleBiometry>(_onToggleBiometry);
    on<UpdateHapticStrength>(_onUpdateHapticStrength);
    on<LoadHapticStrength>(_onLoadHapticStrength);
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

      final passcode = await pinService.getPin();
      final syncEnabled = await settingsRepository.loadSyncEnabled();
      final language = await settingsRepository.loadLanguage();
      final prefs = await SharedPreferences.getInstance();
      final biometryEnabled = prefs.getBool(_biometryKey) ?? false;
      final hapticStrength = await hapticService.getHapticStrength();
              emit(
          SettingsLoaded(
            themeMode: themeMode,
            primaryColor: primaryColor,
            soundsEnabled: soundsEnabled,
            passcode: passcode,
            syncEnabled: syncEnabled,
            language: language,
            biometryEnabled: biometryEnabled,
            hapticStrength: hapticStrength,
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
        final limitedColor = _limitColorBrightness(event.color);
        await settingsRepository.savePrimaryColor(limitedColor);
        // Обновляем системную навигацию сразу
        _updateSystemNavigationColor(limitedColor);
        emit(currentState.copyWith(primaryColor: limitedColor));
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



  Future<void> _onUpdatePasscode(
    UpdatePasscode event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      try {
        // Сохраняем PIN в secure storage
        if (event.passcode != null && event.passcode!.isNotEmpty) {
          await pinService.setPin(event.passcode!);
        } else {
          await pinService.deletePin();
        }
        emit(currentState.copyWith(passcode: event.passcode));
      } catch (e) {
        emit(SettingsError('Failed to save passcode: $e'));
      }
    }
  }

  Future<void> _onSetPin(SetPin event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      try {
        await pinService.setPin(event.pin);
      } catch (e) {
        emit(SettingsError('Failed to set pin: $e'));
      }
    }
  }

  Future<void> _onCheckPin(CheckPin event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      try {
        final isValid = await pinService.checkPin(event.pin);
        // Можно добавить emit состояния для UI
      } catch (e) {
        emit(SettingsError('Failed to check pin: $e'));
      }
    }
  }

  Future<void> _onDeletePin(
    DeletePin event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      try {
        await pinService.deletePin();
        add(const LoadSettings());
      } catch (e) {
        emit(SettingsError('Failed to delete pin: $e'));
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

  Future<void> _onAuthenticateBiometry(
    AuthenticateBiometry event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      try {
        final result = await biometryService.authenticate(reason: event.reason);
        // Можно добавить emit состояния для UI
      } catch (e) {
        emit(SettingsError('Failed to authenticate with biometry: $e'));
      }
    }
  }

  Future<void> _onToggleBiometry(
    ToggleBiometry event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final prefs = await SharedPreferences.getInstance();
      final newValue = !currentState.biometryEnabled;
      await prefs.setBool(_biometryKey, newValue);
      emit(currentState.copyWith(biometryEnabled: newValue));
    }
  }

  Future<void> _onUpdateHapticStrength(
    UpdateHapticStrength event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      try {
        await hapticService.setHapticStrength(event.strength);
        emit(currentState.copyWith(hapticStrength: event.strength));
      } catch (e) {
        emit(SettingsError('Failed to save haptic strength: $e'));
      }
    }
  }

  Future<void> _onLoadHapticStrength(
    LoadHapticStrength event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      try {
        final hapticStrength = await hapticService.getHapticStrength();
        emit(currentState.copyWith(hapticStrength: hapticStrength));
      } catch (e) {
        emit(SettingsError('Failed to load haptic strength: $e'));
      }
    }
  }
}
