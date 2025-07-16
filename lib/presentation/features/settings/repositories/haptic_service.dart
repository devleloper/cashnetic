import 'package:flutter/services.dart';

class HapticService {
  void light() => HapticFeedback.lightImpact();
  void medium() => HapticFeedback.mediumImpact();
  void heavy() => HapticFeedback.heavyImpact();
  void selection() => HapticFeedback.selectionClick();
  void vibrate() => HapticFeedback.vibrate();
}
