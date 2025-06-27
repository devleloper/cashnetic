import 'package:cashnetic/data/database.dart' as db;
import 'package:cashnetic/domain/entities/transaction.dart' as domain;
import 'package:cashnetic/domain/entities/forms/transaction_form.dart';
import 'package:cashnetic/domain/failures/failure.dart';
import 'package:cashnetic/domain/failures/repository_failure.dart';
import 'package:cashnetic/domain/repositories/transaction_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:cashnetic/data/mappers/transaction_mapper.dart';

class DriftTransactionRepository implements TransactionRepository {
  final db.AppDatabase dbInstance;

  DriftTransactionRepository(this.dbInstance);

  domain.Transaction _mapDbToDomain(db.Transaction t) => t.toDomain();

  @override
  Future<Either<Failure, domain.Transaction>> createTransaction(
    TransactionForm transaction,
  ) async {
    try {
      final id = await dbInstance.insertTransaction(
        db.TransactionsCompanion(
          accountId: Value(transaction.accountId!),
          categoryId: transaction.categoryId != null
              ? Value(transaction.categoryId)
              : const Value.absent(),
          amount: Value(transaction.amount!),
          timestamp: Value(transaction.timestamp!),
          comment: transaction.comment != null
              ? Value(transaction.comment)
              : const Value.absent(),
        ),
      );
      final t = await dbInstance.getTransactionById(id);
      if (t == null) {
        return Left(RepositoryFailure('Transaction not found after insert'));
      }
      return Right(_mapDbToDomain(t));
    } catch (e) {
      return Left(RepositoryFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, domain.Transaction>> getTransactionById(int id) async {
    try {
      final t = await dbInstance.getTransactionById(id);
      if (t == null) return Left(RepositoryFailure('Transaction not found'));
      return Right(_mapDbToDomain(t));
    } catch (e) {
      return Left(RepositoryFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, domain.Transaction>> updateTransaction(
    int id,
    TransactionForm transaction,
  ) async {
    try {
      final t = await dbInstance.getTransactionById(id);
      if (t == null) return Left(RepositoryFailure('Transaction not found'));
      final updated = t.copyWith(
        accountId: transaction.accountId ?? t.accountId,
        categoryId: transaction.categoryId != null
            ? Value(transaction.categoryId)
            : Value(t.categoryId),
        amount: transaction.amount ?? t.amount,
        timestamp: transaction.timestamp ?? t.timestamp,
        comment: transaction.comment != null
            ? Value(transaction.comment)
            : Value(t.comment),
      );
      await dbInstance.updateTransaction(updated);
      return Right(_mapDbToDomain(updated));
    } catch (e) {
      return Left(RepositoryFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTransaction(int id) async {
    try {
      await dbInstance.deleteTransaction(id);
      return Right(unit);
    } catch (e) {
      return Left(RepositoryFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<domain.Transaction>>> getTransactionsByPeriod(
    int accountId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final all = await dbInstance.getAllTransactions();
      final filtered = all
          .where(
            (t) =>
                (accountId == 0 || t.accountId == accountId) &&
                t.timestamp.isAfter(startDate) &&
                t.timestamp.isBefore(endDate),
          )
          .map(_mapDbToDomain)
          .toList();
      return Right(filtered);
    } catch (e) {
      return Left(RepositoryFailure(e.toString()));
    }
  }

  @override
  Future<List<domain.Transaction>> getTransactionsByAccount(
    int accountId,
  ) async {
    try {
      final all = await dbInstance.getAllTransactions();
      return all
          .where((t) => t.accountId == accountId)
          .map(_mapDbToDomain)
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> moveTransactionsToAccount(
    int fromAccountId,
    int toAccountId,
  ) async {
    final all = await dbInstance.getAllTransactions();
    final toMove = all.where((t) => t.accountId == fromAccountId).toList();
    for (final t in toMove) {
      final updated = t.copyWith(accountId: toAccountId);
      await dbInstance.updateTransaction(updated);
    }
  }

  @override
  Future<void> deleteTransactionsByAccount(int accountId) async {
    final all = await dbInstance.getAllTransactions();
    final toDelete = all.where((t) => t.accountId == accountId).toList();
    for (final t in toDelete) {
      await dbInstance.deleteTransaction(t.id);
    }
  }
}
