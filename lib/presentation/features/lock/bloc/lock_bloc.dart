import 'package:flutter_bloc/flutter_bloc.dart';
import 'lock_event.dart';
import 'lock_state.dart';
import '../../settings/services/pin_service.dart';
import '../../settings/services/biometry_service.dart';

class LockBloc extends Bloc<LockEvent, LockState> {
  final PinService pinService;
  final BiometryService biometryService;
  final bool biometryEnabled;

  LockBloc({
    required this.pinService,
    required this.biometryService,
    this.biometryEnabled = false,
  }) : super(LockInitial()) {
    on<LoadLock>(_onLoadLock);
    on<EnterPin>(_onEnterPin);
    on<AuthenticateBiometry>(_onAuthenticateBiometry);
    on<Unlock>(_onUnlock);
    on<Lock>(_onLock);
    on<ShowError>(_onShowError);
  }

  void _onLoadLock(LoadLock event, Emitter<LockState> emit) async {
    emit(LockLocked(biometryEnabled: biometryEnabled));
  }

  void _onEnterPin(EnterPin event, Emitter<LockState> emit) async {
    emit(LockLoading());
    final isValid = await pinService.checkPin(event.pin);
    if (isValid) {
      emit(LockUnlocked());
    } else {
      emit(LockError('Invalid PIN'));
      emit(LockLocked(biometryEnabled: biometryEnabled));
    }
  }

  void _onAuthenticateBiometry(
    AuthenticateBiometry event,
    Emitter<LockState> emit,
  ) async {
    emit(LockLoading());
    final result = await biometryService.authenticate(reason: event.reason);
    if (result) {
      emit(LockUnlocked());
    } else {
      emit(LockError('Biometric authentication failed'));
      emit(LockLocked(biometryEnabled: biometryEnabled));
    }
  }

  void _onUnlock(Unlock event, Emitter<LockState> emit) async {
    emit(LockUnlocked());
  }

  void _onLock(Lock event, Emitter<LockState> emit) async {
    emit(LockLocked(biometryEnabled: biometryEnabled));
  }

  void _onShowError(ShowError event, Emitter<LockState> emit) async {
    emit(LockError(event.message));
    emit(LockLocked(biometryEnabled: biometryEnabled));
  }
}
