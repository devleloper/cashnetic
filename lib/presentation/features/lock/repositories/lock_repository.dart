import '../../settings/repositories/pin_service.dart';
import '../../settings/repositories/biometry_service.dart';

class LockRepository {
  final PinService pinService;
  final BiometryService biometryService;

  LockRepository({required this.pinService, required this.biometryService});

  Future<bool> checkPin(String pin) => pinService.checkPin(pin);
  Future<bool> authenticateBiometry({
    String reason = 'Authenticate to unlock',
  }) => biometryService.authenticate(reason: reason);
}
