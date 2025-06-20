import 'package:equatable/equatable.dart';
import 'package:cashnetic/data/models/category/category.dart';
import 'package:cashnetic/data/models/transaction_response/transaction_response.dart';
import 'package:cashnetic/domain/entities/account.dart';

abstract class TransactionEditEvent extends Equatable {
  const TransactionEditEvent();
  @override
  List<Object?> get props => [];
}

class TransactionEditInitialized extends TransactionEditEvent {
  final TransactionResponseDTO transaction;
  const TransactionEditInitialized(this.transaction);
  @override
  List<Object?> get props => [transaction];
}

class TransactionEditCategoryChanged extends TransactionEditEvent {
  final CategoryDTO category;
  const TransactionEditCategoryChanged(this.category);
  @override
  List<Object?> get props => [category];
}

class TransactionEditDateChanged extends TransactionEditEvent {
  final DateTime date;
  const TransactionEditDateChanged(this.date);
  @override
  List<Object?> get props => [date];
}

class TransactionEditAccountChanged extends TransactionEditEvent {
  final Account account;
  const TransactionEditAccountChanged(this.account);
  @override
  List<Object?> get props => [account];
}

class TransactionEditAmountChanged extends TransactionEditEvent {
  final String amount;
  const TransactionEditAmountChanged(this.amount);
  @override
  List<Object?> get props => [amount];
}

class TransactionEditCommentChanged extends TransactionEditEvent {
  final String comment;
  const TransactionEditCommentChanged(this.comment);
  @override
  List<Object?> get props => [comment];
}

class TransactionEditSaveTransaction extends TransactionEditEvent {}

class TransactionEditDeleteTransaction extends TransactionEditEvent {}

class TransactionEditCustomCategoryCreated extends TransactionEditEvent {
  final String name;
  final String emoji;
  final bool isIncome;
  final String color;
  const TransactionEditCustomCategoryCreated({
    required this.name,
    required this.emoji,
    required this.isIncome,
    required this.color,
  });
  @override
  List<Object?> get props => [name, emoji, isIncome, color];
}
