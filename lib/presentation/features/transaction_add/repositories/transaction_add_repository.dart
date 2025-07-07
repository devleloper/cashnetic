import 'package:cashnetic/domain/entities/forms/transaction_form.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'package:cashnetic/domain/entities/account.dart';

abstract class TransactionAddRepository {
  Future<List<Category>> getCategories();
  Future<List<Account>> getAccounts();
  Future<Category?> addTransaction(TransactionForm form);
  String? validateForm(TransactionForm form);
}
