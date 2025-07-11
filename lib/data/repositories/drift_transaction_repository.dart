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
import '../models/transaction_response/transaction_response.dart';
import 'package:uuid/uuid.dart';
import 'package:cashnetic/utils/diff_utils.dart';

class DriftTransactionRepository {
  final db.AppDatabase dbInstance;
  final ApiClient apiClient;

  DriftTransactionRepository(this.dbInstance, this.apiClient);

  domain.Transaction _mapDbToDomain(db.Transaction t) => t.toDomain();

  Future<Either<Failure, domain.Transaction>> createTransaction(
    TransactionForm form,
  ) async {
    try {
      final uuid = Uuid();
      final generatedClientId = uuid.v4();
      final id = await dbInstance.insertTransaction(
        db.TransactionsCompanion(
          clientId: Value(generatedClientId),
          accountId: Value(form.accountId ?? 0),
          categoryId: Value(form.categoryId ?? 0),
          amount: Value(form.amount ?? 0.0),
          timestamp: Value(form.timestamp ?? DateTime.now()),
          comment: Value(form.comment ?? ''),
        ),
      );
      // Save event in pending_events
      final dtoOrFailure = form.toDTO();
      final payload = dtoOrFailure.fold((_) => <String, dynamic>{}, (dto) {
        final map = dto.toJson();
        map['clientId'] = generatedClientId;
        return map;
      });
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
      // --- DIFF LOGIC ---
      final oldJson = TransactionDTO(
        id: existing.id,
        accountId: existing.accountId ?? 0,
        categoryId: existing.categoryId ?? 0,
        amount: existing.amount.toString(),
        transactionDate: existing.timestamp.toIso8601String(),
        comment: existing.comment,
        createdAt: existing.createdAt.toIso8601String(),
        updatedAt: existing.updatedAt.toIso8601String(),
      ).toJson();
      final newJson = TransactionDTO(
        id: updated.id,
        accountId: updated.accountId ?? 0,
        categoryId: updated.categoryId ?? 0,
        amount: updated.amount.toString(),
        transactionDate: updated.timestamp.toIso8601String(),
        comment: updated.comment,
        createdAt: updated.createdAt.toIso8601String(),
        updatedAt: updated.updatedAt.toIso8601String(),
      ).toJson();
      final diff = generateDiff(oldJson, newJson);
      if (diff.isNotEmpty) {
        diff['id'] = id; // always include id for update
        await dbInstance.insertPendingEvent(
          db.PendingEventsCompanion(
            entity: Value('transaction'),
            type: Value('update'),
            payload: Value(jsonEncode(diff)),
            createdAt: Value(DateTime.now()),
            status: Value('pending'),
          ),
        );
        debugPrint(
          '[DriftTransactionRepository] Saved diff to pending_events: ' +
              diff.toString(),
        );
      } else {
        debugPrint(
          '[DriftTransactionRepository] No diff detected, nothing to sync',
        );
      }
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
      // Save event in pending_events
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

  Future<(List<domain.Transaction>, bool)> getTransactionsByPeriod(
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
      List<db.Transaction> filtered;
      if (accountId == ALL_ACCOUNTS_ID) {
        filtered = all
            .where(
              (t) =>
                  t.timestamp.isAfter(startDate) &&
                  t.timestamp.isBefore(endDate),
            )
            .toList();
      } else {
        filtered = all
            .where(
              (t) =>
                  t.accountId == accountId &&
                  t.timestamp.isAfter(startDate) &&
                  t.timestamp.isBefore(endDate),
            )
            .toList();
      }
      debugPrint(
        '[DriftTransactionRepository] Filtered transactions count: ${filtered.length}',
      );
      for (final t in filtered) {
        debugPrint(
          '  - id: ${t.id}, accountId: ${t.accountId}, categoryId: ${t.categoryId}, amount: ${t.amount}, timestamp: ${t.timestamp}',
        );
      }
      debugPrint('[DriftTransactionRepository] EXIT getTransactionsByPeriod');
      return (filtered.map(_mapDbToDomain).toList(), false);
    } catch (e) {
      debugPrint(
        '[DriftTransactionRepository] ERROR in getTransactionsByPeriod: ${e.toString()}',
      );
      return (<domain.Transaction>[], true);
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
        // 1. Find local unsynced transactions (clientId != null && id == null or id not in remote)
        final remoteIds = remoteTransactions.map((t) => t.id).toSet();
        final unsynced = local
            .where((t) => t.id == null || !remoteIds.contains(t.id))
            .toList();
        // 2. Insert server transactions (insertOnConflictUpdate)
        for (final tx in remoteTransactions) {
          await dbInstance
              .into(dbInstance.transactions)
              .insertOnConflictUpdate(tx);
        }
        // 3. Return merged list
        final all = await dbInstance.getAllTransactions();
        return Right(all.map((t) => t.toDomain()).toList());
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

  // --- API SYNC ---
  Future<Either<Failure, List<domain.Transaction>>>
  fetchTransactionsFromApiByPeriod(
    int accountId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      debugPrint(
        '[fetchTransactionsFromApiByPeriod] FORCED accountId=1, original= [33m$accountId [0m',
      );
      final response = await apiClient.dio.get(
        '/transactions/account/1/period',
        queryParameters: {
          'startDate': startDate.toIso8601String().substring(0, 10),
          'endDate': endDate.toIso8601String().substring(0, 10),
        },
      );
      final data = response.data as List;
      final remoteTransactions = <domain.Transaction>[];
      for (final json in data) {
        final dto = TransactionResponseDTO.fromJson(json);
        final domainOrFailure = dto.toDomain();
        domainOrFailure.fold(
          (failure) => debugPrint(
            '[fetchTransactionsFromApiByPeriod] Parse error:  [31m$failure [0m',
          ),
          (domainTx) async {
            // Save to DB
            final dbTx = db.Transaction(
              id: domainTx.id,
              accountId: domainTx.accountId,
              categoryId: domainTx.categoryId,
              amount: domainTx.amount,
              timestamp: domainTx.timestamp,
              comment: domainTx.comment,
              createdAt: domainTx.timeInterval.createdAt,
              updatedAt: domainTx.timeInterval.updatedAt,
            );
            await dbInstance.insertOrReplaceTransaction(dbTx);
            remoteTransactions.add(domainTx);
          },
        );
      }
      return Right(remoteTransactions);
    } catch (e) {
      return Left(RepositoryFailure(e.toString()));
    }
  }

  Future<Either<Failure, domain.Transaction>> fetchTransactionFromApiById(
    int id,
  ) async {
    try {
      final response = await apiClient.getTransaction(id.toString());
      final data = response.data;
      final dto = TransactionDTO.fromJson(data);
      final tx = db.Transaction(
        id: dto.id,
        accountId: dto.accountId,
        categoryId: dto.categoryId,
        amount: double.tryParse(dto.amount) ?? 0.0,
        timestamp: DateTime.parse(dto.transactionDate),
        comment: dto.comment,
        createdAt: DateTime.parse(dto.createdAt),
        updatedAt: DateTime.parse(dto.updatedAt),
      );
      await dbInstance.insertTransaction(
        db.TransactionsCompanion(
          id: Value(tx.id),
          accountId: Value(tx.accountId),
          categoryId: Value(tx.categoryId),
          amount: Value(tx.amount),
          timestamp: Value(tx.timestamp),
          comment: Value(tx.comment ?? ''),
          createdAt: Value(tx.createdAt),
          updatedAt: Value(tx.updatedAt),
        ),
      );
      return Right(tx.toDomain());
    } catch (e) {
      return Left(RepositoryFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<domain.Transaction>>>
  fetchAllTransactionsByPeriod(
    List<int> accountIds,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final futures = accountIds.map(
        (accountId) =>
            fetchTransactionsFromApiByPeriod(accountId, startDate, endDate),
      );
      final results = await Future.wait(futures);
      final allTransactions = <domain.Transaction>[];
      for (final result in results) {
        result.fold(
          (failure) => debugPrint(
            '[fetchAllTransactionsByPeriod] Error:  [31m$failure [0m',
          ),
          (txs) => allTransactions.addAll(txs),
        );
      }
      return Right(allTransactions);
    } catch (e) {
      return Left(RepositoryFailure(e.toString()));
    }
  }
}
