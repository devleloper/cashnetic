import 'package:cashnetic/domain/entities/transaction.dart';
import 'package:cashnetic/domain/entities/category.dart' as domain;
import 'package:cashnetic/domain/entities/account.dart';
import 'transactions_repository.dart';
import 'package:cashnetic/data/repositories/drift_transaction_repository.dart';
import 'package:cashnetic/data/repositories/drift_category_repository.dart';
import 'package:cashnetic/data/repositories/drift_account_repository.dart';
import 'package:cashnetic/di/di.dart';
import 'package:cashnetic/domain/failures/failure.dart';
import 'package:flutter/foundation.dart';
import 'package:cashnetic/domain/constants/constants.dart';

class TransactionsRepositoryImpl implements TransactionsRepository {
  final _transactionRepo = getIt<DriftTransactionRepository>();
  final _categoryRepo = getIt<DriftCategoryRepository>();
  final _accountRepo = getIt<DriftAccountRepository>();

  @override
  Future<List<Transaction>> getTransactions({
    int? accountId,
    int? categoryId,
    DateTime? from,
    DateTime? to,
    int? page,
    int? pageSize,
  }) async {
    debugPrint('[TransactionsRepositoryImpl] ENTER getTransactions');
    List<Transaction> allTransactions = [];
    final testFrom = DateTime(2000, 1, 1);
    final testTo = DateTime(2100, 1, 1);
    if (accountId == ALL_ACCOUNTS_ID) {
      final accountsResult = await _accountRepo.getAllAccounts();
      final accounts = accountsResult.fold((_) => <Account>[], (accs) => accs);
      final ids = accounts.map((a) => a.id).toList();
      final result = await _transactionRepo.fetchAllTransactionsByPeriod(
        ids,
        testFrom,
        testTo,
      );
      allTransactions = result.fold((_) => <Transaction>[], (txs) => txs);
    } else if (accountId != null) {
      await _transactionRepo.fetchTransactionsFromApiByPeriod(
        accountId,
        testFrom,
        testTo,
      );
    }
    final result = await _transactionRepo.getTransactionsByPeriod(
      accountId ?? ALL_ACCOUNTS_ID,
      testFrom,
      testTo,
    );
    var filtered = result.fold((_) => <Transaction>[], (txs) => txs);
    if (accountId == ALL_ACCOUNTS_ID && allTransactions.isNotEmpty) {
      filtered = allTransactions;
    }
    if (categoryId != null) {
      filtered = filtered.where((t) => t.categoryId == categoryId).toList();
    }
    if (page != null && pageSize != null) {
      final start = page * pageSize;
      filtered = filtered.skip(start).take(pageSize).toList();
    }
    debugPrint(
      '[TransactionsRepositoryImpl] Returning transactions count:  [33m${filtered.length}  [0m',
    );
    debugPrint('[TransactionsRepositoryImpl] EXIT getTransactions');
    return filtered;
  }

  /// Получить транзакции по диапазону accountId (от startId до endId включительно)
  Future<List<Transaction>> fetchTransactionsForAccountRange({
    required int startId,
    required int endId,
    DateTime? from,
    DateTime? to,
  }) async {
    final ids = List.generate(endId - startId + 1, (i) => startId + i);
    final testFrom = from ?? DateTime(2000, 1, 1);
    final testTo = to ?? DateTime(2100, 1, 1);
    final futures = ids
        .map(
          (id) => _transactionRepo.fetchTransactionsFromApiByPeriod(
            id,
            testFrom,
            testTo,
          ),
        )
        .toList();
    final results = await Future.wait(futures);
    final allTransactions = <Transaction>[];
    for (final result in results) {
      result.fold((_) {}, (txs) => allTransactions.addAll(txs));
    }
    return allTransactions;
  }

  @override
  Future<List<domain.Category>> getCategories() async {
    final result = await _categoryRepo.getAllCategories();
    return result.fold((_) => <domain.Category>[], (cats) => cats);
  }

  @override
  Future<List<Account>> getAccounts() async {
    final result = await _accountRepo.getAllAccounts();
    return result.fold((_) => <Account>[], (accs) => accs);
  }

  @override
  Future<void> deleteTransaction(int id) async {
    final result = await _transactionRepo.deleteTransaction(id);
    result.fold((failure) => throw Exception(failure.toString()), (_) => null);
  }

  @override
  Future<void> moveTransactionsToAccount(
    int fromAccountId,
    int toAccountId,
  ) async {
    await _transactionRepo.moveTransactionsToAccount(
      fromAccountId,
      toAccountId,
    );
  }

  @override
  Future<void> deleteTransactionsByAccount(int accountId) async {
    await _transactionRepo.deleteTransactionsByAccount(accountId);
  }
}
