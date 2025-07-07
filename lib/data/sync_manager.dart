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
        switch (event.entity) {
          case 'account':
            if (event.type == 'create') {
              await api.createAccount(jsonDecode(event.payload));
            } else if (event.type == 'update') {
              // TODO: реализовать update
            } else if (event.type == 'delete') {
              // TODO: реализовать delete
            }
            break;
          case 'category':
            // TODO: аналогично для категорий
            break;
          case 'transaction':
            // TODO: аналогично для транзакций
            break;
        }
        await db.updatePendingEventStatus(event.id, 'synced');
        await db.deletePendingEvent(event.id);
      } catch (e) {
        await db.updatePendingEventStatus(event.id, 'failed');
      }
    }
  }
}
