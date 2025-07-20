import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum HapticStrength { off, light, medium, heavy }

class HapticService {
  static const String _hapticStrengthKey = 'haptic_strength';
  
  Future<HapticStrength> _getHapticStrength() async {
    final prefs = await SharedPreferences.getInstance();
    final strength = prefs.getString(_hapticStrengthKey) ?? 'medium';
    switch (strength) {
      case 'off':
        return HapticStrength.off;
      case 'light':
        return HapticStrength.light;
      case 'heavy':
        return HapticStrength.heavy;
      default:
        return HapticStrength.medium;
    }
  }

  Future<void> _setHapticStrength(HapticStrength strength) async {
    final prefs = await SharedPreferences.getInstance();
    String strengthString;
    switch (strength) {
      case HapticStrength.off:
        strengthString = 'off';
        break;
      case HapticStrength.light:
        strengthString = 'light';
        break;
      case HapticStrength.heavy:
        strengthString = 'heavy';
        break;
      default:
        strengthString = 'medium';
    }
    await prefs.setString(_hapticStrengthKey, strengthString);
  }

  Future<void> light() async {
    final strength = await _getHapticStrength();
    if (strength == HapticStrength.off) return;
    
    switch (strength) {
      case HapticStrength.light:
        HapticFeedback.lightImpact();
        break;
      case HapticStrength.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticStrength.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticStrength.off:
        break;
    }
  }

  Future<void> medium() async {
    final strength = await _getHapticStrength();
    if (strength == HapticStrength.off) return;
    
    switch (strength) {
      case HapticStrength.light:
        HapticFeedback.lightImpact();
        break;
      case HapticStrength.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticStrength.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticStrength.off:
        break;
    }
  }

  Future<void> heavy() async {
    final strength = await _getHapticStrength();
    if (strength == HapticStrength.off) return;
    
    switch (strength) {
      case HapticStrength.light:
        HapticFeedback.lightImpact();
        break;
      case HapticStrength.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticStrength.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticStrength.off:
        break;
    }
  }

  Future<void> selection() async {
    final strength = await _getHapticStrength();
    if (strength == HapticStrength.off) return;
    
    switch (strength) {
      case HapticStrength.light:
        HapticFeedback.lightImpact();
        break;
      case HapticStrength.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticStrength.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticStrength.off:
        break;
    }
  }

  Future<void> vibrate() async {
    final strength = await _getHapticStrength();
    if (strength == HapticStrength.off) return;
    
    switch (strength) {
      case HapticStrength.light:
        HapticFeedback.lightImpact();
        break;
      case HapticStrength.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticStrength.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticStrength.off:
        break;
    }
  }

  Future<void> setHapticStrength(HapticStrength strength) async {
    await _setHapticStrength(strength);
  }

  Future<HapticStrength> getHapticStrength() async {
    return await _getHapticStrength();
  }
}
