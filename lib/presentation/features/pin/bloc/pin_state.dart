// pin_state.dart
import 'package:equatable/equatable.dart';

abstract class PinState extends Equatable {
  const PinState();
  @override
  List<Object?> get props => [];
}

class PinInitial extends PinState {}
class PinLoading extends PinState {}
class PinSet extends PinState {}
class PinNotSet extends PinState {}
class PinError extends PinState {
  final String message;
  const PinError(this.message);
  @override
  List<Object?> get props => [message];
}
class PinChecked extends PinState {
  final bool isValid;
  const PinChecked(this.isValid);
  @override
  List<Object?> get props => [isValid];
} 