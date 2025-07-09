import 'package:cashnetic/data/database.dart' as db;
import 'package:cashnetic/domain/entities/transaction.dart' as domain;
import 'package:cashnetic/domain/entities/forms/transaction_form.dart';
import 'package:cashnetic/domain/failures/failure.dart';
import 'package:cashnetic/domain/failures/repository_failure.dart';
import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:cashnetic/data/mappers/transaction_mapper.dart';
import 'package:flutter/foundation.dart';
import 'package:cashnetic/data/api_client.dart';
import 'package:cashnetic/data/models/transaction/transaction.dart';
import 'dart:convert';
import 'package:cashnetic/data/mappers/transaction_form_mapper.dart';
import 'package:cashnetic/domain/constants/constants.dart';

class DriftTransactionRepository {
  final db.AppDatabase dbInstance;
  final ApiClient apiClient;

  DriftTransactionRepository(this.dbInstance, this.apiClient);

  domain.Transaction _mapDbToDomain(db.Transaction t) => t.toDomain();

  Future<Either<Failure, domain.Transaction>> createTransaction(
    TransactionForm form,
  ) async {
    try {
      final id = await dbInstance.insertTransaction(
        db.TransactionsCompanion(
          accountId: Value(form.accountId ?? 0),
          categoryId: Value(form.categoryId ?? 0),
          amount: Value(form.amount ?? 0.0),
          timestamp: Value(form.timestamp ?? DateTime.now()),
          comment: Value(form.comment ?? ''),
        ),
      );
      // Сохраняем событие в pending_events
      final dtoOrFailure = form.toDTO();
      final payload = dtoOrFailure.fold(
        (_) => <String, dynamic>{},
        (dto) => dto.toJson(),
      );
      await dbInstance.insertPendingEvent(
        db.PendingEventsCompanion(
          entity: Value('transaction'),
          type: Value('create'),
          payload: Value(jsonEncode(payload)),
          createdAt: Value(DateTime.now()),
          status: Value('pending'),
        ),
      );
      final tx = await dbInstance.getTransactionById(id);
      if (tx == null) {
        return Left(RepositoryFailure('Transaction not found after insert'));
      }
      return Right(tx.toDomain());
    } catch (e) {
      return Left(RepositoryFailure(e.toString()));
    }
  }

  Future<Either<Failure, domain.Transaction>> getTransactionById(int id) async {
    try {
      final t = await dbInstance.getTransactionById(id);
      if (t == null) return Left(RepositoryFailure('Transaction not found'));
      return Right(_mapDbToDomain(t));
    } catch (e) {
      return Left(RepositoryFailure(e.toString()));
    }
  }

  Future<Either<Failure, domain.Transaction>> updateTransaction(
    int id,
    TransactionForm form,
  ) async {
    try {
      final existing = await dbInstance.getTransactionById(id);
      if (existing == null) {
        return Left(RepositoryFailure('Transaction not found'));
      }
      final updated = existing.copyWith(
        accountId: form.accountId ?? existing.accountId,
        categoryId: form.categoryId != null
            ? Value(form.categoryId)
            : const Value.absent(),
        amount: form.amount ?? existing.amount,
        timestamp: form.timestamp ?? existing.timestamp,
        comment: form.comment != null
            ? Value(form.comment)
            : const Value.absent(),
        updatedAt: DateTime.now(),
      );
      await dbInstance.updateTransaction(updated);
      // Сохраняем событие в pending_events
      final dtoOrFailure = form.toDTO();
      final payload = dtoOrFailure.fold((_) => <String, dynamic>{}, (dto) {
        final map = dto.toJson();
        map['id'] = id;
        return map;
      });
      await dbInstance.insertPendingEvent(
        db.PendingEventsCompanion(
          entity: Value('transaction'),
          type: Value('update'),
          payload: Value(jsonEncode(payload)),
          createdAt: Value(DateTime.now()),
          status: Value('pending'),
        ),
      );
      final tx = await dbInstance.getTransactionById(id);
      if (tx == null) {
        return Left(RepositoryFailure('Transaction not found after update'));
      }
      return Right(tx.toDomain());
    } catch (e) {
      return Left(RepositoryFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deleteTransaction(int id) async {
    try {
      await dbInstance.deleteTransaction(id);
      // Сохраняем событие в pending_events
      await dbInstance.insertPendingEvent(
        db.PendingEventsCompanion(
          entity: Value('transaction'),
          type: Value('delete'),
          payload: Value(jsonEncode({'id': id})),
          createdAt: Value(DateTime.now()),
          status: Value('pending'),
        ),
      );
      return Right(null);
    } catch (e) {
      return Left(RepositoryFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<domain.Transaction>>> getTransactionsByPeriod(
    int accountId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    debugPrint(
      '[DriftTransactionRepository] ENTER getTransactionsByPeriod: accountId= [33m$accountId [0m, startDate=$startDate, endDate=$endDate',
    );
    try {
      final all = await dbInstance.getAllTransactions();
      debugPrint(
        '[DriftTransactionRepository] All transactions count:  [33m${all.length} [0m',
      );
      final filtered = all
          .where(
            (t) =>
                (accountId == ALL_ACCOUNTS_ID || t.accountId == accountId) &&
                t.timestamp.isAfter(startDate) &&
                t.timestamp.isBefore(endDate),
          )
          .map(_mapDbToDomain)
          .toList();
      debugPrint(
        '[DriftTransactionRepository] Filtered transactions count: ${filtered.length}',
      );
      for (final t in filtered) {
        debugPrint(
          '  - id: ${t.id}, accountId: ${t.accountId}, categoryId: ${t.categoryId}, amount: ${t.amount}, timestamp: ${t.timestamp}',
        );
      }
      debugPrint('[DriftTransactionRepository] EXIT getTransactionsByPeriod');
      return Right(filtered);
    } catch (e) {
      debugPrint(
        '[DriftTransactionRepository] ERROR in getTransactionsByPeriod: ${e.toString()}',
      );
      return Left(RepositoryFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<domain.Transaction>>> getAllTransactions() async {
    try {
      final local = await dbInstance.getAllTransactions();
      try {
        final response = await apiClient.getTransactions();
        final remoteTransactions = (response.data as List)
            .map((json) => TransactionDTO.fromJson(json))
            .map(
              (dto) => db.Transaction(
                id: dto.id,
                accountId: dto.accountId,
                categoryId: dto.categoryId,
                amount: double.tryParse(dto.amount) ?? 0.0,
                timestamp: DateTime.parse(dto.transactionDate),
                comment: dto.comment,
                createdAt: DateTime.parse(dto.createdAt),
                updatedAt: DateTime.parse(dto.updatedAt),
              ),
            )
            .toList();
        await dbInstance.replaceAllTransactions(remoteTransactions);
        return Right(remoteTransactions.map((t) => t.toDomain()).toList());
      } catch (_) {
        return Right(local.map((e) => e.toDomain()).toList());
      }
    } catch (e) {
      return Left(RepositoryFailure(e.toString()));
    }
  }

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

  Future<void> deleteTransactionsByAccount(int accountId) async {
    final all = await dbInstance.getAllTransactions();
    final toDelete = all.where((t) => t.accountId == accountId).toList();
    for (final t in toDelete) {
      await dbInstance.deleteTransaction(t.id);
    }
  }
}
