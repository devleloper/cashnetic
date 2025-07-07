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
import 'package:cashnetic/data/api_client.dart';
import 'package:cashnetic/data/models/account/account.dart';
import 'dart:convert';
import 'package:cashnetic/data/mappers/account_form_mapper.dart';

class DriftAccountRepository {
  final db.AppDatabase dbInstance;
  final ApiClient apiClient;

  DriftAccountRepository(this.dbInstance, this.apiClient);

  Future<Either<Failure, List<domain.Account>>> getAllAccounts() async {
    try {
      // 1. Получаем локально
      final local = await dbInstance.getAllAccounts();
      // 2. Пробуем обновить с сервера
      try {
        final response = await apiClient.getAccounts();
        final remoteAccounts = (response.data as List)
            .map((json) => AccountDTO.fromJson(json))
            .map(
              (dto) => db.Account(
                id: dto.id,
                name: dto.name,
                currency: dto.currency,
                balance: double.tryParse(dto.balance) ?? 0.0,
                createdAt: DateTime.parse(dto.createdAt),
                updatedAt: DateTime.parse(dto.updatedAt),
              ),
            )
            .toList();
        // 3. Обновляем локальную БД
        await dbInstance.replaceAllAccounts(remoteAccounts);
        return Right(remoteAccounts.map((a) => a.toDomain()).toList());
      } catch (_) {
        // 4. Если ошибка — возвращаем локальные данные
        return Right(local.map((e) => e.toDomain()).toList());
      }
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
      // Сохраняем событие в pending_events
      await dbInstance.insertPendingEvent(
        db.PendingEventsCompanion(
          entity: Value('account'),
          type: Value('create'),
          payload: Value(jsonEncode(account.toCreateDTO().toJson())),
          createdAt: Value(DateTime.now()),
          status: Value('pending'),
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
