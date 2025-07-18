import 'package:flutter/material.dart';

abstract class SettingsRepository {
  Future<ThemeMode> loadThemeMode();
  Future<void> saveThemeMode(ThemeMode mode);

  Future<Color> loadPrimaryColor();
  Future<void> savePrimaryColor(Color color);

  Future<int> loadPrimaryColorValue();
  Future<void> savePrimaryColorValue(int colorValue);

  Future<bool> loadSoundsEnabled();
  Future<void> saveSoundsEnabled(bool enabled);



  Future<String?> loadPasscode();
  Future<void> savePasscode(String? passcode);

  Future<bool> loadSyncEnabled();
  Future<void> saveSyncEnabled(bool enabled);

  Future<String> loadLanguage();
  Future<void> saveLanguage(String language);
}
