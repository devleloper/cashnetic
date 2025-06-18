import 'package:equatable/equatable.dart';
import 'package:cashnetic/data/models/category/category.dart';

abstract class TransactionAddEvent extends Equatable {
  const TransactionAddEvent();
  @override
  List<Object?> get props => [];
}

class TransactionAddInitialized extends TransactionAddEvent {
  final bool isIncome;
  const TransactionAddInitialized(this.isIncome);
  @override
  List<Object?> get props => [isIncome];
}

class TransactionAddCategoryChanged extends TransactionAddEvent {
  final CategoryDTO category;
  const TransactionAddCategoryChanged(this.category);
  @override
  List<Object?> get props => [category];
}

class TransactionAddDateChanged extends TransactionAddEvent {
  final DateTime date;
  const TransactionAddDateChanged(this.date);
  @override
  List<Object?> get props => [date];
}

class TransactionAddAccountChanged extends TransactionAddEvent {
  final String account;
  const TransactionAddAccountChanged(this.account);
  @override
  List<Object?> get props => [account];
}

class TransactionAddAmountChanged extends TransactionAddEvent {
  final String amount;
  const TransactionAddAmountChanged(this.amount);
  @override
  List<Object?> get props => [amount];
}

class TransactionAddCommentChanged extends TransactionAddEvent {
  final String comment;
  const TransactionAddCommentChanged(this.comment);
  @override
  List<Object?> get props => [comment];
}

class TransactionAddSaveTransaction extends TransactionAddEvent {}
