// pin_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'pin_event.dart';
import 'pin_state.dart';
import '../repositories/pin_repository.dart';

class PinBloc extends Bloc<PinEvent, PinState> {
  final PinRepository pinRepository;
  PinBloc({required this.pinRepository}) : super(PinInitial()) {
    on<LoadPin>(_onLoadPin);
    on<SetPin>(_onSetPin);
    on<CheckPin>(_onCheckPin);
    on<DeletePin>(_onDeletePin);
  }

  Future<void> _onLoadPin(LoadPin event, Emitter<PinState> emit) async {
    emit(PinLoading());
    final pin = await pinRepository.getPin();
    if (pin != null && pin.isNotEmpty) {
      emit(PinSet());
    } else {
      emit(PinNotSet());
    }
  }

  Future<void> _onSetPin(SetPin event, Emitter<PinState> emit) async {
    emit(PinLoading());
    try {
      if (event.pin.length != 4) {
        emit(const PinError('PIN must be 4 digits'));
        return;
      }
      await pinRepository.setPin(event.pin);
      emit(PinSet());
    } catch (e) {
      emit(PinError('Failed to set PIN: $e'));
    }
  }

  Future<void> _onCheckPin(CheckPin event, Emitter<PinState> emit) async {
    emit(PinLoading());
    try {
      final isValid = await pinRepository.checkPin(event.pin);
      emit(PinChecked(isValid));
    } catch (e) {
      emit(PinError('Failed to check PIN: $e'));
    }
  }

  Future<void> _onDeletePin(DeletePin event, Emitter<PinState> emit) async {
    emit(PinLoading());
    try {
      await pinRepository.deletePin();
      emit(PinNotSet());
    } catch (e) {
      emit(PinError('Failed to delete PIN: $e'));
    }
  }
} 