// pin_repository.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class PinRepository {
  Future<void> setPin(String pin);
  Future<String?> getPin();
  Future<void> deletePin();
  Future<bool> checkPin(String pin);
}

class PinRepositoryImpl implements PinRepository {
  static const _pinKey = 'user_pin';
  final FlutterSecureStorage _storage;
  PinRepositoryImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> setPin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
  }

  @override
  Future<String?> getPin() async {
    return await _storage.read(key: _pinKey);
  }

  @override
  Future<void> deletePin() async {
    await _storage.delete(key: _pinKey);
  }

  @override
  Future<bool> checkPin(String pin) async {
    final storedPin = await getPin();
    return storedPin == pin;
  }
} 