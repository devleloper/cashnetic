// pin_event.dart
import 'package:equatable/equatable.dart';

abstract class PinEvent extends Equatable {
  const PinEvent();
  @override
  List<Object?> get props => [];
}

class LoadPin extends PinEvent {}
class SetPin extends PinEvent {
  final String pin;
  const SetPin(this.pin);
  @override
  List<Object?> get props => [pin];
}
class CheckPin extends PinEvent {
  final String pin;
  const CheckPin(this.pin);
  @override
  List<Object?> get props => [pin];
}
class DeletePin extends PinEvent {} 