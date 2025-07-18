import 'package:flutter/widgets.dart';

typedef AppLifecycleCallback = void Function(AppLifecycleState state);

class AppLifecycleService with WidgetsBindingObserver {
  final List<AppLifecycleCallback> _listeners = [];

  AppLifecycleService() {
    WidgetsBinding.instance.addObserver(this);
  }

  void addListener(AppLifecycleCallback callback) {
    _listeners.add(callback);
  }

  void removeListener(AppLifecycleCallback callback) {
    _listeners.remove(callback);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    for (final listener in _listeners) {
      listener(state);
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _listeners.clear();
  }
}
