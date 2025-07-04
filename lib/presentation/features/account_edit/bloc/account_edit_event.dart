import 'package:equatable/equatable.dart';
import 'package:cashnetic/domain/entities/account.dart';

abstract class AccountEditEvent extends Equatable {
  const AccountEditEvent();
  @override
  List<Object?> get props => [];
}

class AccountEditInitialized extends AccountEditEvent {
  final Account account;
  const AccountEditInitialized(this.account);
  @override
  List<Object?> get props => [account];
}

class AccountEditNameChanged extends AccountEditEvent {
  final String name;
  const AccountEditNameChanged(this.name);
  @override
  List<Object?> get props => [name];
}

class AccountEditBalanceChanged extends AccountEditEvent {
  final String balance;
  const AccountEditBalanceChanged(this.balance);
  @override
  List<Object?> get props => [balance];
}

class AccountEditCurrencyChanged extends AccountEditEvent {
  final String currency;
  const AccountEditCurrencyChanged(this.currency);
  @override
  List<Object?> get props => [currency];
}

class AccountEditSubmitted extends AccountEditEvent {}
