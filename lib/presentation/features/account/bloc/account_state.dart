import 'package:equatable/equatable.dart';
import 'package:cashnetic/data/models/account/account.dart';
import 'package:cashnetic/domain/entities/account.dart';

class DailyBalancePoint {
  final DateTime date;
  final double income;
  final double expense;
  const DailyBalancePoint(this.date, this.income, this.expense);
}

abstract class AccountState extends Equatable {
  const AccountState();
  @override
  List<Object?> get props => [];
}

class AccountLoading extends AccountState {}

class AccountLoaded extends AccountState {
  final AccountDTO account;
  final List<DailyBalancePoint> dailyPoints;
  final double computedBalance;
  final List<Account> accounts;
  final int selectedAccountId;
  final List<int> selectedAccountIds;
  const AccountLoaded({
    required this.account,
    required this.dailyPoints,
    required this.computedBalance,
    required this.accounts,
    required this.selectedAccountId,
    required this.selectedAccountIds,
  });
  @override
  List<Object?> get props => [
    account,
    dailyPoints,
    computedBalance,
    accounts,
    selectedAccountId,
    selectedAccountIds,
  ];
}

class AccountError extends AccountState {
  final String message;
  const AccountError(this.message);
  @override
  List<Object?> get props => [message];
}
