import 'package:flutter/material.dart';

abstract class SettingsRepository {
  Future<ThemeMode> loadThemeMode();
  Future<void> saveThemeMode(ThemeMode mode);

  Future<int> loadPrimaryColor();
  Future<void> savePrimaryColor(int colorValue);

  Future<bool> loadSoundsEnabled();
  Future<void> saveSoundsEnabled(bool enabled);

  Future<bool> loadHapticsEnabled();
  Future<void> saveHapticsEnabled(bool enabled);

  Future<String?> loadPasscode();
  Future<void> savePasscode(String? passcode);

  Future<bool> loadSyncEnabled();
  Future<void> saveSyncEnabled(bool enabled);

  Future<String> loadLanguage();
  Future<void> saveLanguage(String language);
}
