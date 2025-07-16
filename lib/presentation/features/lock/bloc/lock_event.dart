import 'package:equatable/equatable.dart';

abstract class LockEvent extends Equatable {
  const LockEvent();
  @override
  List<Object?> get props => [];
}

class LoadLock extends LockEvent {}

class EnterPin extends LockEvent {
  final String pin;
  const EnterPin(this.pin);
  @override
  List<Object?> get props => [pin];
}

class AuthenticateBiometry extends LockEvent {
  final String reason;
  const AuthenticateBiometry({this.reason = 'Authenticate to unlock'});
  @override
  List<Object?> get props => [reason];
}

class Unlock extends LockEvent {}

class Lock extends LockEvent {}

class ShowError extends LockEvent {
  final String message;
  const ShowError(this.message);
  @override
  List<Object?> get props => [message];
}
