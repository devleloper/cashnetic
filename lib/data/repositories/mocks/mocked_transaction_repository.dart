import 'package:dartz/dartz.dart';
import 'package:cashnetic/domain/entities/forms/transaction_form.dart';
import 'package:cashnetic/domain/entities/transaction.dart';
import 'package:cashnetic/domain/entities/value_objects/time_interval.dart';
import 'package:cashnetic/domain/failures/failure.dart';
import 'package:cashnetic/domain/failures/repository_failure.dart';

class MockedTransactionRepository {
  final List<Transaction> _transactions = [
    Transaction(
      id: 1,
      accountId: 1,
      categoryId: 1,
      amount: 412,
      timestamp: DateTime.now(),
      comment: 'Mocked Transaction',
      timeInterval: TimeInterval(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ),
  ];

  int _nextId() {
    final usedIds = _transactions.map((a) => a.id).toSet();
    int id = 1;
    while (usedIds.contains(id)) {
      id++;
    }
    return id;
  }

  Future<Either<Failure, Transaction>> createTransaction(
    TransactionForm form,
  ) async {
    try {
      final transaction = Transaction(
        id: _nextId(),
        accountId: form.accountId!,
        categoryId: form.categoryId!,
        comment: form.comment ?? '',
        amount: form.amount ?? 0.0,
        timestamp: form.timestamp ?? DateTime.now(),
        timeInterval: TimeInterval(
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      _transactions.add(transaction);
      return right(transaction);
    } catch (e) {
      return left(RepositoryFailure('Ошибка при создании транзакции'));
    }
  }

  Future<Either<Failure, Unit>> deleteTransaction(int id) async {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index == -1) {
      return left(RepositoryFailure('Транзакция с id $id не найдена'));
    }
    _transactions.removeAt(index);
    return right(unit);
  }

  Future<Either<Failure, Transaction>> getTransactionById(int id) async {
    final transaction = _transactions.where((a) => a.id == id).firstOrNull;
    if (transaction == null) {
      return left(RepositoryFailure('Транзакция с id $id не найдена'));
    }
    return right(transaction);
  }

  Future<Either<Failure, List<Transaction>>> getTransactionsByPeriod(
    int accountId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final filtered = _transactions.where((t) {
      return t.accountId == accountId &&
          t.timestamp.isAfter(startDate) &&
          t.timestamp.isBefore(endDate);
    }).toList();
    return right(filtered);
  }

  Future<Either<Failure, Transaction>> updateTransaction(
    int id,
    TransactionForm form,
  ) async {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index == -1) {
      return left(RepositoryFailure('Транзакция с id $id не найдена'));
    }

    final existing = _transactions[index];
    final updated = Transaction(
      id: id,
      accountId: form.accountId ?? existing.accountId,
      categoryId: form.categoryId ?? existing.categoryId,
      comment: form.comment ?? existing.comment,
      amount: form.amount ?? existing.amount,
      timestamp: form.timestamp ?? existing.timestamp,
      timeInterval: TimeInterval(
        createdAt: existing.timeInterval.createdAt,
        updatedAt: DateTime.now(),
      ),
    );

    _transactions[index] = updated;
    return right(updated);
  }

  Future<List<Transaction>> getTransactionsByAccount(int accountId) async {
    return _transactions.where((t) => t.accountId == accountId).toList();
  }

  Future<void> moveTransactionsToAccount(
    int fromAccountId,
    int toAccountId,
  ) async {
    for (var i = 0; i < _transactions.length; i++) {
      if (_transactions[i].accountId == fromAccountId) {
        _transactions[i] = Transaction(
          id: _transactions[i].id,
          accountId: toAccountId,
          categoryId: _transactions[i].categoryId,
          comment: _transactions[i].comment,
          amount: _transactions[i].amount,
          timestamp: _transactions[i].timestamp,
          timeInterval: _transactions[i].timeInterval,
        );
      }
    }
  }

  Future<void> deleteTransactionsByAccount(int accountId) async {
    _transactions.removeWhere((t) => t.accountId == accountId);
  }
}
