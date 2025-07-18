import 'package:equatable/equatable.dart';

abstract class LockState extends Equatable {
  const LockState();
  @override
  List<Object?> get props => [];
}

class LockInitial extends LockState {}

class LockLoading extends LockState {}

class LockLocked extends LockState {
  final bool biometryEnabled;
  const LockLocked({this.biometryEnabled = false});
  @override
  List<Object?> get props => [biometryEnabled];
}

class LockUnlocked extends LockState {}

class LockError extends LockState {
  final String message;
  const LockError(this.message);
  @override
  List<Object?> get props => [message];
}
