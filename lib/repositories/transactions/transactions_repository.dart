import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/transactions/transaction_model.dart';

abstract class TransactionsRepository {
  Future<List<TransactionModel>> loadTransactions();
  Future<void> addTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(int id);
  Future<void> updateTransaction(TransactionModel transaction);

  Future<List<TransactionModel>> loadByCategory(int categoryId);
}

class TransactionsRepositoryImpl implements TransactionsRepository {
  static const _storageKey = 'transactions_storage';
  List<TransactionModel> _cache = [];

  Future<void> _loadCache() async {
    if (_cache.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString(_storageKey);
      if (rawJson != null) {
        final List<dynamic> decoded = jsonDecode(rawJson);
        _cache = decoded
            .map((item) => TransactionModel.fromJson(item))
            .toList();
      }
    }
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_cache.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, json);
  }

  @override
  Future<List<TransactionModel>> loadTransactions() async {
    await _loadCache();
    return List.unmodifiable(_cache);
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    await _loadCache();
    _cache.add(transaction);
    await _saveToStorage();
  }

  @override
  Future<void> deleteTransaction(int id) async {
    await _loadCache();
    _cache.removeWhere((t) => t.id == id);
    await _saveToStorage();
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    await _loadCache();
    final index = _cache.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _cache[index] = transaction;
      await _saveToStorage();
    }
  }

  @override
  Future<List<TransactionModel>> loadByCategory(int categoryId) async {
    await _loadCache();
    return _cache
        .where((t) => t.categoryId == categoryId)
        .toList(growable: false);
  }
}
