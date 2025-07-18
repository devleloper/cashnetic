import 'package:local_auth/local_auth.dart';

class BiometryService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    return await _auth.canCheckBiometrics && await _auth.isDeviceSupported();
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      return <BiometricType>[];
    }
  }

  Future<bool> authenticate({String reason = 'Authenticate to access'}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }
}
