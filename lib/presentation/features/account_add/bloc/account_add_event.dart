import 'package:equatable/equatable.dart';

abstract class AccountAddEvent extends Equatable {
  const AccountAddEvent();
  @override
  List<Object?> get props => [];
}

class AccountAddNameChanged extends AccountAddEvent {
  final String name;
  const AccountAddNameChanged(this.name);
  @override
  List<Object?> get props => [name];
}

class AccountAddBalanceChanged extends AccountAddEvent {
  final String balance;
  const AccountAddBalanceChanged(this.balance);
  @override
  List<Object?> get props => [balance];
}

class AccountAddCurrencyChanged extends AccountAddEvent {
  final String currency;
  const AccountAddCurrencyChanged(this.currency);
  @override
  List<Object?> get props => [currency];
}

class AccountAddSubmitted extends AccountAddEvent {}
