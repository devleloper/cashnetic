import 'dart:convert';
import 'package:cashnetic/data/database.dart';
import 'package:cashnetic/data/api_client.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:cashnetic/data/models/account_create/account_request.dart';
import 'package:cashnetic/data/models/category/category.dart';
import 'package:cashnetic/data/models/transaction_request/transaction_request.dart';

class SyncManager {
  final AppDatabase db;
  final ApiClient api;
  bool _isSyncing = false;

  SyncManager(this.db, this.api);

  Future<void> sync() async {
    if (_isSyncing) {
      debugPrint('[SyncManager] Sync already in progress, skipping');
      return;
    }
    _isSyncing = true;
    final events = await db.getAllPendingEvents();
    for (final event in events) {
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
              final response = await api.createTransaction(dto);
              final serverData = response.data;
              final serverId = serverData['id'];
              final clientId = payload['clientId'];
              if (clientId != null && serverId != null) {
                // Обновляем локальную транзакцию: ищем по clientId, обновляем id
                final tx = await db
                    .customSelect(
                      'SELECT * FROM transactions WHERE client_id = ? LIMIT 1',
                      variables: [Variable.withString(clientId)],
                    )
                    .getSingleOrNull();
                if (tx != null) {
                  await db.customUpdate(
                    'UPDATE transactions SET id = ? WHERE client_id = ?',
                    variables: [
                      Variable.withInt(serverId),
                      Variable.withString(clientId),
                    ],
                    updates: {db.transactions},
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
                await api.updateTransaction(id.toString(), dto);
              } else if (clientId != null) {
                // Ищем локально по clientId, если нет serverId
                final tx = await db
                    .customSelect(
                      'SELECT * FROM transactions WHERE client_id = ? LIMIT 1',
                      variables: [Variable.withString(clientId)],
                    )
                    .getSingleOrNull();
                if (tx != null) {
                  await api.updateTransaction(tx.data['id'].toString(), dto);
                }
              }
            } else if (event.type == 'delete') {
              final id = payload['id'];
              final clientId = payload['clientId'];
              if (id != null) {
                await api.deleteTransaction(id.toString());
              } else if (clientId != null) {
                final tx = await db
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
        await db.updatePendingEventStatus(event.id, 'synced');
        await db.deletePendingEvent(event.id);
      } catch (e) {
        debugPrint('[SyncManager] Sync error: $e');
        await db.updatePendingEventStatus(event.id, 'failed');
      }
    }
    _isSyncing = false;
  }

  Future<void> retryFailed() async {
    final failedEvents = (await db.getAllPendingEvents())
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
        await db.updatePendingEventStatus(event.id, 'synced');
        await db.deletePendingEvent(event.id);
      } catch (e) {
        // Оставляем статус failed
      }
    }
  }
}
