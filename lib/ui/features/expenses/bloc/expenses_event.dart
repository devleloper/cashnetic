import 'package:equatable/equatable.dart';

abstract class ExpensesEvent extends Equatable {
  const ExpensesEvent();
  @override
  List<Object?> get props => [];
}

class LoadExpenses extends ExpensesEvent {}

class AddExpense extends ExpensesEvent {
  final dynamic transaction; // уточним тип после интеграции domain/data
  const AddExpense(this.transaction);
  @override
  List<Object?> get props => [transaction];
}

class DeleteExpense extends ExpensesEvent {
  final int transactionId;
  const DeleteExpense(this.transactionId);
  @override
  List<Object?> get props => [transactionId];
}

class UpdateExpense extends ExpensesEvent {
  final dynamic transaction; // уточним тип после интеграции domain/data
  const UpdateExpense(this.transaction);
  @override
  List<Object?> get props => [transaction];
}
