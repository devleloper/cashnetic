import 'package:cashnetic/domain/entities/transaction.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'package:cashnetic/domain/entities/account.dart';

abstract class TransactionsRepository {
  Future<(List<Transaction>, bool)> getTransactions({
    int? accountId,
    int? categoryId,
    DateTime? from,
    DateTime? to,
    int? page,
    int? pageSize,
  });
  Future<List<Category>> getCategories();
  Future<List<Account>> getAccounts();
  Future<void> deleteTransaction(int id);
  Future<void> moveTransactionsToAccount(int fromAccountId, int toAccountId);
  Future<void> deleteTransactionsByAccount(int accountId);
}
