import 'dart:convert';
import 'package:cashnetic/data/database.dart';
import 'package:cashnetic/data/api_client.dart';

class SyncManager {
  final AppDatabase db;
  final ApiClient api;

  SyncManager(this.db, this.api);

  Future<void> sync() async {
    final events = await db.getAllPendingEvents();
    for (final event in events) {
      try {
        final payload = jsonDecode(event.payload);
        switch (event.entity) {
          case 'account':
            if (event.type == 'create') {
              await api.createAccount(payload);
            } else if (event.type == 'update') {
              await api.updateAccount(payload['id'].toString(), payload);
            } else if (event.type == 'delete') {
              await api.deleteAccount(payload['id'].toString());
            }
            break;
          case 'category':
            if (event.type == 'create') {
              await api.createCategory(payload);
            } else if (event.type == 'update') {
              await api.updateCategory(payload['id'].toString(), payload);
            } else if (event.type == 'delete') {
              await api.deleteCategory(payload['id'].toString());
            }
            break;
          case 'transaction':
            if (event.type == 'create') {
              await api.createTransaction(payload);
            } else if (event.type == 'update') {
              await api.updateTransaction(payload['id'].toString(), payload);
            } else if (event.type == 'delete') {
              await api.deleteTransaction(payload['id'].toString());
            }
            break;
        }
        await db.updatePendingEventStatus(event.id, 'synced');
        await db.deletePendingEvent(event.id);
      } catch (e) {
        await db.updatePendingEventStatus(event.id, 'failed');
      }
    }
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
            if (event.type == 'create') {
              await api.createAccount(payload);
            } else if (event.type == 'update') {
              await api.updateAccount(payload['id'].toString(), payload);
            } else if (event.type == 'delete') {
              await api.deleteAccount(payload['id'].toString());
            }
            break;
          case 'category':
            if (event.type == 'create') {
              await api.createCategory(payload);
            } else if (event.type == 'update') {
              await api.updateCategory(payload['id'].toString(), payload);
            } else if (event.type == 'delete') {
              await api.deleteCategory(payload['id'].toString());
            }
            break;
          case 'transaction':
            if (event.type == 'create') {
              await api.createTransaction(payload);
            } else if (event.type == 'update') {
              await api.updateTransaction(payload['id'].toString(), payload);
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
