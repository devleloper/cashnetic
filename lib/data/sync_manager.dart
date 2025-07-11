import 'dart:convert';
import 'package:cashnetic/data/database.dart' as db;
import 'package:cashnetic/data/api_client.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:cashnetic/data/models/account_create/account_request.dart';
import 'package:cashnetic/data/models/account/account.dart';
import 'package:cashnetic/data/models/transaction/transaction.dart';
import 'package:cashnetic/data/models/category/category.dart';
import 'package:cashnetic/data/models/transaction_request/transaction_request.dart';
import 'package:cashnetic/di/di.dart';
import 'package:cashnetic/data/repositories/drift_account_repository.dart';
import 'package:cashnetic/data/repositories/drift_category_repository.dart';
import 'package:cashnetic/data/repositories/drift_transaction_repository.dart';

class SyncManager {
  final db.AppDatabase dbInstance;
  final ApiClient api;
  bool _isSyncing = false;

  SyncManager(this.dbInstance, this.api);

  Future<void> sync() async {
    if (_isSyncing) {
      debugPrint('[SyncManager] Sync already in progress, skipping');
      return;
    }
    _isSyncing = true;
    final events = await dbInstance.getAllPendingEvents();
    for (final event in events) {
      try {
        final payload = jsonDecode(event.payload);
        switch (event.entity) {
          case 'account':
            if (event.type == 'create') {
              final dto = AccountRequestDTO.fromJson(payload);
              final response = await api.createAccount(dto);
              final serverData = response.data;
              final serverId = serverData['id'];
              final localId = payload['id'];
              if (serverId != null && localId != null) {
                // Update accountId for all transactions that referenced the local id
                await dbInstance.customUpdate(
                  'UPDATE transactions SET account_id = ? WHERE account_id = ?',
                  variables: [
                    Variable.withInt(serverId),
                    Variable.withInt(localId),
                  ],
                  updates: {dbInstance.transactions},
                );
                debugPrint(
                  '[SyncManager] Updated local transactions accountId=$localId → serverId=$serverId',
                );
              }
            } else if (event.type == 'update') {
              await api.patchAccount(payload['id'].toString(), payload);
            } else if (event.type == 'delete') {
              await api.deleteAccount(payload['id'].toString());
            }
            break;
          case 'category':
            if (event.type == 'create') {
              final dto = CategoryDTO.fromJson(payload);
              await api.createCategory(dto);
            } else if (event.type == 'update') {
              await api.patchCategory(payload['id'].toString(), payload);
            } else if (event.type == 'delete') {
              await api.deleteCategory(payload['id'].toString());
            }
            break;
          case 'transaction':
            if (event.type == 'create') {
              final dto = TransactionRequestDTO.fromJson(payload);
              final response = await api.createTransaction(dto);
              final serverData = response.data;
              final serverId = serverData['id'];
              final clientId = payload['clientId'];
              if (clientId != null && serverId != null) {
                // Update local transaction: find by clientId, update id
                final tx = await dbInstance
                    .customSelect(
                      'SELECT * FROM transactions WHERE client_id = ? LIMIT 1',
                      variables: [Variable.withString(clientId)],
                    )
                    .getSingleOrNull();
                if (tx != null) {
                  await dbInstance.customUpdate(
                    'UPDATE transactions SET id = ? WHERE client_id = ?',
                    variables: [
                      Variable.withInt(serverId),
                      Variable.withString(clientId),
                    ],
                    updates: {dbInstance.transactions},
                  );
                  debugPrint(
                    '[SyncManager] Updated local transaction clientId=$clientId → serverId=$serverId',
                  );
                }
              }
            } else if (event.type == 'update') {
              final id = payload['id'];
              final clientId = payload['clientId'];
              if (id != null) {
                await api.patchTransaction(id.toString(), payload);
              } else if (clientId != null) {
                // Find locally by clientId if no serverId
                final tx = await dbInstance
                    .customSelect(
                      'SELECT * FROM transactions WHERE client_id = ? LIMIT 1',
                      variables: [Variable.withString(clientId)],
                    )
                    .getSingleOrNull();
                if (tx != null) {
                  await api.patchTransaction(tx.data['id'].toString(), payload);
                }
              }
            } else if (event.type == 'delete') {
              final id = payload['id'];
              final clientId = payload['clientId'];
              if (id != null) {
                await api.deleteTransaction(id.toString());
              } else if (clientId != null) {
                final tx = await dbInstance
                    .customSelect(
                      'SELECT * FROM transactions WHERE client_id = ? LIMIT 1',
                      variables: [Variable.withString(clientId)],
                    )
                    .getSingleOrNull();
                if (tx != null) {
                  await api.deleteTransaction(tx.data['id'].toString());
                }
              }
            }
            break;
        }
        await dbInstance.updatePendingEventStatus(event.id, 'synced');
        await dbInstance.deletePendingEvent(event.id);
      } catch (e) {
        debugPrint('[SyncManager] Sync error: $e');
        await dbInstance.updatePendingEventStatus(event.id, 'failed');
      }
    }
    _isSyncing = false;
  }

  /// Retry all failed events in the pending_events table
  Future<void> retryFailed() async {
    final failedEvents = (await dbInstance.getAllPendingEvents())
        .where((e) => e.status == 'failed')
        .toList();
    for (final event in failedEvents) {
      try {
        final payload = jsonDecode(event.payload);
        switch (event.entity) {
          case 'account':
            final dto = AccountRequestDTO.fromJson(payload);
            if (event.type == 'create') {
              await api.createAccount(dto);
            } else if (event.type == 'update') {
              await api.updateAccount(payload['id'].toString(), dto);
            } else if (event.type == 'delete') {
              await api.deleteAccount(payload['id'].toString());
            }
            break;
          case 'category':
            final dto = CategoryDTO.fromJson(payload);
            if (event.type == 'create') {
              await api.createCategory(dto);
            } else if (event.type == 'update') {
              await api.updateCategory(payload['id'].toString(), dto);
            } else if (event.type == 'delete') {
              await api.deleteCategory(payload['id'].toString());
            }
            break;
          case 'transaction':
            final dto = TransactionRequestDTO.fromJson(payload);
            if (event.type == 'create') {
              await api.createTransaction(dto);
            } else if (event.type == 'update') {
              await api.updateTransaction(payload['id'].toString(), dto);
            } else if (event.type == 'delete') {
              await api.deleteTransaction(payload['id'].toString());
            }
            break;
        }
        await dbInstance.updatePendingEventStatus(event.id, 'synced');
        await dbInstance.deletePendingEvent(event.id);
      } catch (e) {
        // Keep status as failed
      }
    }
  }

  /// Fetch all data from API and update local database (accounts, categories, transactions)
  Future<void> fullSync() async {
    debugPrint('[SyncManager] Starting fullSync: fetch all from API');
    try {
      // Accounts
      final lastAccountRev = await dbInstance.getLastRevision('account');
      debugPrint('[SyncManager] Fetching accounts since: $lastAccountRev');
      final accountsResp = await api.getAccounts(since: lastAccountRev);
      if (accountsResp.data is List && accountsResp.data.isNotEmpty) {
        for (final json in accountsResp.data) {
          if (json['deleted'] == true) {
            debugPrint(
              '[SyncManager] Deleting account id=${json['id']} (server-deleted)',
            );
            await dbInstance.deleteAccount(json['id']);
            continue;
          }
          debugPrint('[SyncManager] Upserting account id=${json['id']}');
          final dto = AccountDTO.fromJson(json);
          final acc = db.Account(
            id: dto.id,
            clientId: dto.clientId,
            name: dto.name,
            currency: dto.currency,
            balance: double.tryParse(dto.balance) ?? 0.0,
            createdAt: DateTime.parse(dto.createdAt),
            updatedAt: DateTime.parse(dto.updatedAt),
          );
          await dbInstance
              .into(dbInstance.accounts)
              .insertOnConflictUpdate(acc);
        }
        final latest = accountsResp.data.last;
        if (latest['updatedAt'] != null) {
          debugPrint(
            '[SyncManager] Set lastRevision for accounts: ${latest['updatedAt']}',
          );
          await dbInstance.setLastRevision('account', latest['updatedAt']);
        }
      }
      // Categories
      final lastCatRev = await dbInstance.getLastRevision('category');
      debugPrint('[SyncManager] Fetching categories since: $lastCatRev');
      final categoriesResp = await api.getCategories(since: lastCatRev);
      if (categoriesResp.data is List && categoriesResp.data.isNotEmpty) {
        for (final json in categoriesResp.data) {
          if (json['deleted'] == true) {
            debugPrint(
              '[SyncManager] Deleting category id=${json['id']} (server-deleted)',
            );
            await dbInstance.deleteCategory(json['id']);
            continue;
          }
          debugPrint('[SyncManager] Upserting category id=${json['id']}');
          final dto = CategoryDTO.fromJson(json);
          final cat = db.Category(
            id: dto.id,
            name: dto.name,
            emoji: dto.emoji,
            isIncome: dto.isIncome,
            color: dto.color ?? '#E0E0E0',
          );
          await dbInstance
              .into(dbInstance.categories)
              .insertOnConflictUpdate(cat);
        }
        final latest = categoriesResp.data.last;
        if (latest['updatedAt'] != null) {
          debugPrint(
            '[SyncManager] Set lastRevision for categories: ${latest['updatedAt']}',
          );
          await dbInstance.setLastRevision('category', latest['updatedAt']);
        }
      }
      // Transactions
      final lastTxRev = await dbInstance.getLastRevision('transaction');
      debugPrint('[SyncManager] Fetching transactions since: $lastTxRev');
      final txResp = await api.getTransactions(since: lastTxRev);
      if (txResp.data is List && txResp.data.isNotEmpty) {
        for (final json in txResp.data) {
          if (json['deleted'] == true) {
            debugPrint(
              '[SyncManager] Deleting transaction id=${json['id']} (server-deleted)',
            );
            await dbInstance.deleteTransaction(json['id']);
            continue;
          }
          debugPrint('[SyncManager] Upserting transaction id=${json['id']}');
          final dto = TransactionDTO.fromJson(json);
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
          await dbInstance
              .into(dbInstance.transactions)
              .insertOnConflictUpdate(tx);
        }
        final latest = txResp.data.last;
        if (latest['updatedAt'] != null) {
          debugPrint(
            '[SyncManager] Set lastRevision for transactions: ${latest['updatedAt']}',
          );
          await dbInstance.setLastRevision('transaction', latest['updatedAt']);
        }
      }
      debugPrint('[SyncManager] fullSync complete');
    } catch (e) {
      debugPrint('[SyncManager] fullSync error: $e');
    }
  }
}
