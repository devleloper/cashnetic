import 'package:dartz/dartz.dart';
import 'package:cashnetic/domain/entities/account.dart';
import 'package:cashnetic/domain/entities/account_history.dart';
import 'package:cashnetic/domain/entities/account_response.dart';
import 'package:cashnetic/domain/entities/forms/account_form.dart';
import 'package:cashnetic/domain/failures/failure.dart';

abstract interface class AccountRepository {
  Future<Either<Failure, List<Account>>> getAllAccounts();

  Future<Either<Failure, Account>> createAccount(AccountForm account);

  Future<Either<Failure, AccountResponse>> getAccountById(int id);

  Future<Either<Failure, AccountForm>> updateAccount(
    int id,
    AccountForm account,
  );

  Future<Either<Failure, AccountHistory>> getAccountHistory(int id);

  Future<void> deleteAccount(int id);
}
