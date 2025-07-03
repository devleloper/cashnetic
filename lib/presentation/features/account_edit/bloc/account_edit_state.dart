import 'package:equatable/equatable.dart';
import 'package:cashnetic/domain/entities/account.dart';

abstract class AccountEditState extends Equatable {
  const AccountEditState();
  @override
  List<Object?> get props => [];
}

class AccountEditInitial extends AccountEditState {}

class AccountEditLoaded extends AccountEditState {
  final Account account;
  final String name;
  final String balance;
  final String currency;
  const AccountEditLoaded({
    required this.account,
    required this.name,
    required this.balance,
    required this.currency,
  });
  @override
  List<Object?> get props => [account, name, balance, currency];
}

class AccountEditLoading extends AccountEditState {}

class AccountEditSuccess extends AccountEditState {}

class AccountEditError extends AccountEditState {
  final String message;
  const AccountEditError(this.message);
  @override
  List<Object?> get props => [message];
}
