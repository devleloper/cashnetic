import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../repositories/settings_repository.dart';
import 'package:cashnetic/data/repositories/theme_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  static const String _primaryColorKey = 'primary_color';
  static const String _soundsKey = 'sounds_enabled';
  static const String _hapticsKey = 'haptics_enabled';
  static const String _passcodeKey = 'passcode';
  static const String _syncKey = 'sync_enabled';
  static const String _languageKey = 'language';

  final ThemeRepository _themeRepository = ThemeRepository();

  @override
  Future<ThemeMode> loadThemeMode() async {
    final themeString = await _themeRepository.loadThemeMode();
    if (themeString == 'light') return ThemeMode.light;
    if (themeString == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  @override
  Future<void> saveThemeMode(ThemeMode mode) async {
    await _themeRepository.saveThemeMode(mode.name);
  }

  @override
  Future<int> loadPrimaryColor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_primaryColorKey) ?? 0xFF2196F3;
  }

  @override
  Future<void> savePrimaryColor(int colorValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_primaryColorKey, colorValue);
  }

  @override
  Future<bool> loadSoundsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundsKey) ?? true;
  }

  @override
  Future<void> saveSoundsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundsKey, enabled);
  }

  @override
  Future<bool> loadHapticsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hapticsKey) ?? true;
  }

  @override
  Future<void> saveHapticsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticsKey, enabled);
  }

  @override
  Future<String?> loadPasscode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_passcodeKey);
  }

  @override
  Future<void> savePasscode(String? passcode) async {
    final prefs = await SharedPreferences.getInstance();
    if (passcode != null) {
      await prefs.setString(_passcodeKey, passcode);
    } else {
      await prefs.remove(_passcodeKey);
    }
  }

  @override
  Future<bool> loadSyncEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_syncKey) ?? false;
  }

  @override
  Future<void> saveSyncEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_syncKey, enabled);
  }

  @override
  Future<String> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
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
    return language;
  }

  @override
  Future<void> saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }
}
