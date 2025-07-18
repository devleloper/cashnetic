import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PinService {
  static const _pinKey = 'user_pin';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> setPin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
  }

  Future<String?> getPin() async {
    return await _storage.read(key: _pinKey);
  }

  Future<void> deletePin() async {
    await _storage.delete(key: _pinKey);
  }

  Future<bool> checkPin(String pin) async {
    final storedPin = await getPin();
    return storedPin == pin;
  }
}
