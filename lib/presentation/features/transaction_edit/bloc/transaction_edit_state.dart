import 'package:equatable/equatable.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'package:cashnetic/domain/entities/transaction.dart';
import 'package:cashnetic/domain/entities/account.dart';

abstract class TransactionEditState extends Equatable {
  const TransactionEditState();
  @override
  List<Object?> get props => [];
}

class TransactionEditInitial extends TransactionEditState {}

class TransactionEditLoading extends TransactionEditState {}

class TransactionEditLoaded extends TransactionEditState {
  final Transaction transaction;
  final List<Category> categories;
  final Category? selectedCategory;
  final DateTime selectedDate;
  final Account account;
  final String amount;
  final String comment;
  final List<Account> accounts;

  const TransactionEditLoaded({
    required this.transaction,
    required this.categories,
    this.selectedCategory,
    required this.selectedDate,
    required this.account,
    required this.amount,
    required this.comment,
    required this.accounts,
  });

  @override
  List<Object?> get props => [
    transaction,
    categories,
    selectedCategory,
    selectedDate,
    account,
    amount,
    comment,
    accounts,
  ];
}

class TransactionEditSaving extends TransactionEditState {
  final Transaction transaction;
  final List<Category> categories;
  final Category? selectedCategory;
  final DateTime selectedDate;
  final Account account;
  final String amount;
  final String comment;
  final List<Account> accounts;

  const TransactionEditSaving({
    required this.transaction,
    required this.categories,
    this.selectedCategory,
    required this.selectedDate,
    required this.account,
    required this.amount,
    required this.comment,
    required this.accounts,
  });

  @override
  List<Object?> get props => [
    transaction,
    categories,
    selectedCategory,
    selectedDate,
    account,
    amount,
    comment,
    accounts,
  ];
}

class TransactionEditDeleting extends TransactionEditState {
  final Transaction transaction;
  final List<Category> categories;
  final Category? selectedCategory;
  final DateTime selectedDate;
  final Account account;
  final String amount;
  final String comment;
  final List<Account> accounts;

  const TransactionEditDeleting({
    required this.transaction,
    required this.categories,
    this.selectedCategory,
    required this.selectedDate,
    required this.account,
    required this.amount,
    required this.comment,
    required this.accounts,
  });

  @override
  List<Object?> get props => [
    transaction,
    categories,
    selectedCategory,
    selectedDate,
    account,
    amount,
    comment,
    accounts,
  ];
}

class TransactionEditError extends TransactionEditState {
  final String message;
  const TransactionEditError(this.message);
  @override
  List<Object?> get props => [message];
}

class TransactionEditSuccess extends TransactionEditState {}

class TransactionEditDeleted extends TransactionEditState {}
