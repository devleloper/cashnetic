import 'package:equatable/equatable.dart';

abstract class AccountAddState extends Equatable {
  const AccountAddState();
  @override
  List<Object?> get props => [];
}

class AccountAddInitial extends AccountAddState {}

class AccountAddLoading extends AccountAddState {}

class AccountAddSuccess extends AccountAddState {}

class AccountAddError extends AccountAddState {
  final String message;
  const AccountAddError(this.message);
  @override
  List<Object?> get props => [message];
}

class AccountAddLoaded extends AccountAddState {
  final String name;
  final String balance;
  final String currency;
  const AccountAddLoaded({
    required this.name,
    required this.balance,
    required this.currency,
  });
  @override
  List<Object?> get props => [name, balance, currency];
}
