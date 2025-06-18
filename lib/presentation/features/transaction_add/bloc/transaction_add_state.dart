import 'package:equatable/equatable.dart';
import 'package:cashnetic/data/models/category/category.dart';

abstract class TransactionAddState extends Equatable {
  const TransactionAddState();
  @override
  List<Object?> get props => [];
}

class TransactionAddInitial extends TransactionAddState {}

class TransactionAddLoading extends TransactionAddState {}

class TransactionAddLoaded extends TransactionAddState {
  final List<CategoryDTO> categories;
  final CategoryDTO? selectedCategory;
  final DateTime selectedDate;
  final String account;
  final String amount;
  final String comment;
  final List<String> accounts;

  const TransactionAddLoaded({
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
    categories,
    selectedCategory,
    selectedDate,
    account,
    amount,
    comment,
    accounts,
  ];
}

class TransactionAddSaving extends TransactionAddState {
  final List<CategoryDTO> categories;
  final CategoryDTO? selectedCategory;
  final DateTime selectedDate;
  final String account;
  final String amount;
  final String comment;
  final List<String> accounts;

  const TransactionAddSaving({
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
    categories,
    selectedCategory,
    selectedDate,
    account,
    amount,
    comment,
    accounts,
  ];
}

class TransactionAddError extends TransactionAddState {
  final String message;
  const TransactionAddError(this.message);
  @override
  List<Object?> get props => [message];
}

class TransactionAddSuccess extends TransactionAddState {}
