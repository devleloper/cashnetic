import 'package:cashnetic/data/database.dart' as db;
import 'package:cashnetic/domain/entities/transaction.dart' as domain;
import 'package:cashnetic/domain/entities/forms/transaction_form.dart';
import 'package:cashnetic/domain/failures/failure.dart';
import 'package:cashnetic/domain/failures/repository_failure.dart';
import 'package:cashnetic/domain/repositories/transaction_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';

class DriftTransactionRepository implements TransactionRepository {
  final db.AppDatabase dbInstance;

  DriftTransactionRepository(this.dbInstance);

  domain.Transaction _mapDbToDomain(db.Transaction t) => domain.Transaction(
    id: t.id,
    accountId: t.accountId,
    categoryId: t.categoryId,
    amount: t.amount,
    timestamp: t.timestamp,
    comment: t.comment,
    timeInterval: throw UnimplementedError(), // доработать под свою модель
  );

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
      if (t == null)
        return Left(RepositoryFailure('Transaction not found after insert'));
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
                t.accountId == accountId &&
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
}
