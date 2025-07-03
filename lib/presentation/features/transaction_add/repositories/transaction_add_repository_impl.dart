import 'package:cashnetic/domain/entities/forms/transaction_form.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'package:cashnetic/domain/entities/account.dart';
import 'transaction_add_repository.dart';
import 'package:cashnetic/data/repositories/drift_transaction_repository.dart';
import 'package:cashnetic/data/repositories/drift_category_repository.dart';
import 'package:cashnetic/data/repositories/drift_account_repository.dart';
import 'package:cashnetic/di/di.dart';
import 'package:cashnetic/domain/failures/failure.dart';

class TransactionAddRepositoryImpl implements TransactionAddRepository {
  final _transactionRepo = getIt<DriftTransactionRepository>();
  final _categoryRepo = getIt<DriftCategoryRepository>();
  final _accountRepo = getIt<DriftAccountRepository>();

  @override
  Future<List<Category>> getCategories() async {
    final result = await _categoryRepo.getAllCategories();
    return result.fold((_) => <Category>[], (cats) => cats);
  }

  @override
  Future<List<Account>> getAccounts() async {
    final result = await _accountRepo.getAllAccounts();
    return result.fold((_) => <Account>[], (accs) => accs);
  }

  @override
  Future<void> addTransaction(TransactionForm form) async {
    final result = await _transactionRepo.createTransaction(form);
    result.fold((failure) => throw Exception(failure.toString()), (_) => null);
  }

  @override
  String? validateForm(TransactionForm form) {
    if (form.amount == null || form.amount! <= 0) {
      return 'Amount must be greater than zero';
    }
    if (form.accountId == null) {
      return 'Account is required';
    }
    if (form.categoryId == null) {
      return 'Category is required';
    }
    return null;
  }
}
