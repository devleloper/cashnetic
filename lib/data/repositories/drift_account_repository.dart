import 'package:cashnetic/data/database.dart' as db;
import 'package:cashnetic/domain/entities/account.dart';
import 'package:cashnetic/domain/entities/forms/account_form.dart';
import 'package:cashnetic/domain/entities/account_response.dart';
import 'package:cashnetic/domain/entities/account_history.dart';
import 'package:cashnetic/domain/failures/failure.dart';
import 'package:cashnetic/domain/failures/repository_failure.dart';
import 'package:cashnetic/domain/repositories/account_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';

class DriftAccountRepository implements AccountRepository {
  final db.AppDatabase dbInstance;

  DriftAccountRepository(this.dbInstance);

  @override
  Future<Either<Failure, List<Account>>> getAllAccounts() async {
    try {
      final data = await dbInstance.getAllAccounts();
      // TODO: Преобразовать db.AccountsData в Account (добавить преобразование moneyDetails и timeInterval)
      return Right(
        data
            .map(
              (e) => Account(
                id: e.id,
                userId: 0, // доработать под свою модель
                name: e.name,
                moneyDetails: /* TODO */ throw UnimplementedError(),
                timeInterval: /* TODO */ throw UnimplementedError(),
              ),
            )
            .toList(),
      );
    } catch (e) {
      return Left(RepositoryFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Account>> createAccount(AccountForm account) async {
    try {
      final id = await dbInstance.insertAccount(
        db.AccountsCompanion(
          name: Value(account.name ?? ''),
          currency: Value(account.moneyDetails?.currency ?? 'RUB'),
          balance: Value(account.moneyDetails?.balance ?? 0.0),
        ),
      );
      final acc = await dbInstance.getAccountById(id);
      if (acc == null)
        return Left(RepositoryFailure('Account not found after insert'));
      return Right(
        Account(
          id: acc.id,
          userId: 0,
          name: acc.name,
          moneyDetails: /* TODO */ throw UnimplementedError(),
          timeInterval: /* TODO */ throw UnimplementedError(),
        ),
      );
    } catch (e) {
      return Left(RepositoryFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AccountResponse>> getAccountById(int id) async {
    // TODO: реализовать
    return Left(RepositoryFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, AccountForm>> updateAccount(
    int id,
    AccountForm account,
  ) async {
    // TODO: реализовать
    return Left(RepositoryFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, AccountHistory>> getAccountHistory(int id) async {
    // TODO: реализовать
    return Left(RepositoryFailure('Not implemented'));
  }
}
