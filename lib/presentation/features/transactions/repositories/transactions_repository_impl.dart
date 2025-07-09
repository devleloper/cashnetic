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
    final result = await _transactionRepo.getTransactionsByPeriod(
      accountId ?? ALL_ACCOUNTS_ID,
      from ?? DateTime.now().subtract(const Duration(days: 30)),
      to ?? DateTime.now(),
    );
    final txs = result.fold((_) => <Transaction>[], (txs) => txs);
    var filtered = txs;
    if (categoryId != null) {
      filtered = filtered.where((t) => t.categoryId == categoryId).toList();
    }
    if (page != null && pageSize != null) {
      final start = page * pageSize;
      final end = start + pageSize;
      filtered = filtered.skip(start).take(pageSize).toList();
    }
    debugPrint(
      '[TransactionsRepositoryImpl] Returning transactions count: ${filtered.length}',
    );
    debugPrint('[TransactionsRepositoryImpl] EXIT getTransactions');
    return filtered;
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
