import 'package:cashnetic/data/database.dart' as db;
import 'package:cashnetic/domain/entities/account.dart' as domain;
import 'package:cashnetic/domain/entities/forms/account_form.dart';
import 'package:cashnetic/domain/entities/account_response.dart';
import 'package:cashnetic/domain/entities/account_history.dart';
import 'package:cashnetic/domain/failures/failure.dart';
import 'package:cashnetic/domain/failures/repository_failure.dart';
import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:cashnetic/domain/entities/value_objects/money_details.dart';
import 'package:cashnetic/domain/entities/value_objects/time_interval.dart';
import 'package:cashnetic/data/mappers/account_mapper.dart';

class DriftAccountRepository {
  final db.AppDatabase dbInstance;

  DriftAccountRepository(this.dbInstance);

  Future<Either<Failure, List<domain.Account>>> getAllAccounts() async {
    try {
      final data = await dbInstance.getAllAccounts();
      return Right(data.map((e) => e.toDomain()).toList());
    } catch (e) {
      return Left(RepositoryFailure(e.toString()));
    }
  }

  Future<Either<Failure, domain.Account>> createAccount(
    AccountForm account,
  ) async {
    try {
      final id = await dbInstance.insertAccount(
        db.AccountsCompanion(
          name: Value(account.name ?? ''),
          currency: Value(account.moneyDetails?.currency ?? 'RUB'),
          balance: Value(account.moneyDetails?.balance ?? 0.0),
        ),
      );
      final acc = await dbInstance.getAccountById(id);
      if (acc == null) {
        return Left(RepositoryFailure('Account not found after insert'));
      }
      return Right(acc.toDomain());
    } catch (e) {
      return Left(RepositoryFailure(e.toString()));
    }
  }

  Future<Either<Failure, AccountResponse>> getAccountById(int id) async {
    try {
      final acc = await dbInstance.getAccountById(id);
      if (acc == null) return Left(RepositoryFailure('Account not found'));
      // AccountResponse требует incomeStats, expenseStats, timeInterval
      // Здесь возвращаем только базовую информацию (incomeStats/expenseStats пустые)
      return Right(
        AccountResponse(
          id: acc.id,
          name: acc.name,
          moneyDetails: MoneyDetails(
            balance: acc.balance,
            currency: acc.currency,
          ),
          incomeStats: [],
          expenseStats: [],
          timeInterval: TimeInterval(
            createdAt: acc.createdAt,
            updatedAt: acc.updatedAt,
          ),
        ),
      );
    } catch (e) {
      return Left(RepositoryFailure(e.toString()));
    }
  }

  Future<Either<Failure, AccountForm>> updateAccount(
    int id,
    AccountForm account,
  ) async {
    try {
      final acc = await dbInstance.getAccountById(id);
      if (acc == null) return Left(RepositoryFailure('Account not found'));
      final updated = acc.copyWith(
        name: account.name ?? acc.name,
        currency: account.moneyDetails?.currency ?? acc.currency,
        balance: account.moneyDetails?.balance ?? acc.balance,
        updatedAt: DateTime.now(),
      );
      await dbInstance.updateAccount(updated);
      return Right(
        AccountForm(
          name: updated.name,
          moneyDetails: MoneyDetails(
            balance: updated.balance,
            currency: updated.currency,
          ),
        ),
      );
    } catch (e) {
      return Left(RepositoryFailure(e.toString()));
    }
  }

  Future<Either<Failure, AccountHistory>> getAccountHistory(int id) async {
    // TODO: Реализовать историю аккаунта (например, выборка транзакций по аккаунту)
    return Left(RepositoryFailure('Not implemented'));
  }

  Future<void> deleteAccount(int id) async {
    await dbInstance.deleteAccount(id);
  }
}
