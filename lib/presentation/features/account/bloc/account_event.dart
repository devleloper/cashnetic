import 'package:equatable/equatable.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object?> get props => [];
}

class LoadAccount extends AccountEvent {}

class UpdateAccountName extends AccountEvent {
  final String newName;
  const UpdateAccountName(this.newName);
  @override
  List<Object?> get props => [newName];
}

class UpdateAccountCurrency extends AccountEvent {
  final String newCurrency;
  const UpdateAccountCurrency(this.newCurrency);
  @override
  List<Object?> get props => [newCurrency];
}

class UpdateAccountBalance extends AccountEvent {
  final double newBalance;
  const UpdateAccountBalance(this.newBalance);
  @override
  List<Object?> get props => [newBalance];
}

class UpdateAccount extends AccountEvent {
  final dynamic updated;
  const UpdateAccount(this.updated);
  @override
  List<Object?> get props => [updated];
}

class SelectAccount extends AccountEvent {
  final int accountId;
  const SelectAccount(this.accountId);
  @override
  List<Object?> get props => [accountId];
}

class SelectAccounts extends AccountEvent {
  final List<int> accountIds;
  const SelectAccounts(this.accountIds);
  @override
  List<Object?> get props => [accountIds];
}
