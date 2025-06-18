import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dartz/dartz.dart';
import 'package:cashnetic/domain/entities/forms/transaction_form.dart';
import 'package:cashnetic/domain/entities/transaction.dart';
import 'package:cashnetic/domain/entities/value_objects/time_interval.dart';
import 'package:cashnetic/domain/failures/failure.dart';
import 'package:cashnetic/domain/failures/repository_failure.dart';
import 'package:cashnetic/domain/repositories/transaction_repository.dart';

class SharedPreferencesTransactionRepository implements TransactionRepository {
  static const String _key = 'transactions';

  Future<List<Map<String, dynamic>>> _loadRawList() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }

  Future<void> _saveRawList(List<Map<String, dynamic>> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(list);
    await prefs.setString(_key, jsonString);
  }

  int _nextId(List<Map<String, dynamic>> list) {
    if (list.isEmpty) return 1;
    final ids = list.map((e) => e['id'] as int).toList();
    return (ids.isEmpty ? 0 : ids.reduce((a, b) => a > b ? a : b)) + 1;
  }

  Transaction _fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int,
      accountId: json['accountId'] as int,
      categoryId: json['categoryId'] as int,
      amount: (json['amount'] as num).toDouble(),
      timestamp: DateTime.parse(json['transactionDate'] as String),
      comment: json['comment'] as String?,
      timeInterval: TimeInterval(
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      ),
    );
  }

  Map<String, dynamic> _toJson(Transaction t) {
    return {
      'id': t.id,
      'accountId': t.accountId,
      'categoryId': t.categoryId,
      'amount': t.amount,
      'transactionDate': t.timestamp.toIso8601String(),
      'comment': t.comment,
      'createdAt': t.timeInterval.createdAt.toIso8601String(),
      'updatedAt': t.timeInterval.updatedAt.toIso8601String(),
    };
  }

  @override
  Future<Either<Failure, Transaction>> createTransaction(
    TransactionForm form,
  ) async {
    try {
      final list = await _loadRawList();
      final id = _nextId(list);
      final now = DateTime.now();
      final t = Transaction(
        id: id,
        accountId: form.accountId!,
        categoryId: form.categoryId!,
        amount: form.amount ?? 0.0,
        timestamp: now,
        comment: form.comment,
        timeInterval: TimeInterval(createdAt: now, updatedAt: now),
      );
      list.add(_toJson(t));
      await _saveRawList(list);
      return right(t);
    } catch (e) {
      return left(RepositoryFailure('Ошибка при создании транзакции: $e'));
    }
  }

  @override
  Future<Either<Failure, Transaction>> getTransactionById(int id) async {
    try {
      final list = await _loadRawList();
      final json = list.firstWhere((e) => e['id'] == id, orElse: () => {});
      if (json.isEmpty) {
        return left(RepositoryFailure('Транзакция с id $id не найдена'));
      }
      return right(_fromJson(json));
    } catch (e) {
      return left(RepositoryFailure('Ошибка при получении транзакции: $e'));
    }
  }

  @override
  Future<Either<Failure, Transaction>> updateTransaction(
    int id,
    TransactionForm form,
  ) async {
    try {
      final list = await _loadRawList();
      final index = list.indexWhere((e) => e['id'] == id);
      if (index == -1) {
        return left(RepositoryFailure('Транзакция с id $id не найдена'));
      }
      final now = DateTime.now();
      final old = _fromJson(list[index]);
      final updated = Transaction(
        id: id,
        accountId: form.accountId ?? old.accountId,
        categoryId: form.categoryId ?? old.categoryId,
        amount: form.amount ?? old.amount,
        timestamp: now,
        comment: form.comment ?? old.comment,
        timeInterval: TimeInterval(
          createdAt: old.timeInterval.createdAt,
          updatedAt: now,
        ),
      );
      list[index] = _toJson(updated);
      await _saveRawList(list);
      return right(updated);
    } catch (e) {
      return left(RepositoryFailure('Ошибка при обновлении транзакции: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTransaction(int id) async {
    try {
      final list = await _loadRawList();
      final index = list.indexWhere((e) => e['id'] == id);
      if (index == -1) {
        return left(RepositoryFailure('Транзакция с id $id не найдена'));
      }
      list.removeAt(index);
      await _saveRawList(list);
      return right(unit);
    } catch (e) {
      return left(RepositoryFailure('Ошибка при удалении транзакции: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactionsByPeriod(
    int accountId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final list = await _loadRawList();
      final filtered = list.map(_fromJson).where((t) {
        return t.accountId == accountId &&
            t.timestamp.isAfter(startDate) &&
            t.timestamp.isBefore(endDate);
      }).toList();
      return right(filtered);
    } catch (e) {
      return left(RepositoryFailure('Ошибка при получении транзакций: $e'));
    }
  }
}
