import 'package:equatable/equatable.dart';
import 'package:cashnetic/domain/entities/transaction.dart';

abstract class IncomesEvent extends Equatable {
  const IncomesEvent();
  @override
  List<Object?> get props => [];
}

class LoadIncomes extends IncomesEvent {}

class RefreshIncomes extends IncomesEvent {}

class AddIncome extends IncomesEvent {
  final Transaction transaction;
  const AddIncome(this.transaction);
  @override
  List<Object?> get props => [transaction];
}

class DeleteIncome extends IncomesEvent {
  final int transactionId;
  const DeleteIncome(this.transactionId);
  @override
  List<Object?> get props => [transactionId];
}

class UpdateIncome extends IncomesEvent {
  final Transaction transaction;
  const UpdateIncome(this.transaction);
  @override
  List<Object?> get props => [transaction];
}
