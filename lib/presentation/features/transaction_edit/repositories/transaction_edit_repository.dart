import 'package:cashnetic/domain/entities/forms/transaction_form.dart';
import 'package:cashnetic/domain/entities/transaction.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'package:cashnetic/domain/entities/account.dart';

abstract class TransactionEditRepository {
  Future<Transaction> getTransactionById(int id);
  Future<List<Category>> getCategories();
  Future<List<Account>> getAccounts();
  Future<void> updateTransaction(int id, TransactionForm form);
  Future<void> deleteTransaction(int id);
  String? validateForm(TransactionForm form);
}
