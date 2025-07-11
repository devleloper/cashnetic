import 'package:equatable/equatable.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'package:cashnetic/domain/entities/account.dart';
import 'package:cashnetic/domain/entities/transaction.dart';
import 'package:flutter/material.dart';

abstract class TransactionAddState extends Equatable {
  const TransactionAddState();
  @override
  List<Object?> get props => [];
}

class TransactionAddInitial extends TransactionAddState {}

class TransactionAddLoading extends TransactionAddState {}

class TransactionAddLoaded extends TransactionAddState {
  final List<Category> categories;
  final Category? selectedCategory;
  final DateTime selectedDate;
  final Account? account;
  final String amount;
  final String comment;
  final List<Account> accounts;
  final bool isIncome;

  const TransactionAddLoaded({
    required this.categories,
    this.selectedCategory,
    required this.selectedDate,
    this.account,
    required this.amount,
    required this.comment,
    required this.accounts,
    required this.isIncome,
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
    isIncome,
  ];
}

class TransactionAddSaving extends TransactionAddState {
  final List<Category> categories;
  final Category? selectedCategory;
  final DateTime selectedDate;
  final Account? account;
  final String amount;
  final String comment;
  final List<Account> accounts;
  final bool isIncome;

  const TransactionAddSaving({
    required this.categories,
    this.selectedCategory,
    required this.selectedDate,
    this.account,
    required this.amount,
    required this.comment,
    required this.accounts,
    required this.isIncome,
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
    isIncome,
  ];
}

class TransactionAddError extends TransactionAddState {
  final String message;
  const TransactionAddError(this.message);
  @override
  List<Object?> get props => [message];
}

class TransactionAddSuccess extends TransactionAddState {
  final String categoryEmoji;
  final Color categoryColor;
  final DateTime selectedDate;
  const TransactionAddSuccess({
    required this.categoryEmoji,
    required this.categoryColor,
    required this.selectedDate,
  });
  @override
  List<Object?> get props => [categoryEmoji, categoryColor, selectedDate];
}
