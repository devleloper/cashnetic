import 'package:dartz/dartz.dart';
import 'package:cashnetic/domain/entities/account.dart';
import 'package:cashnetic/domain/entities/account_history.dart';
import 'package:cashnetic/domain/entities/account_response.dart';
import 'package:cashnetic/domain/entities/forms/account_form.dart';
import 'package:cashnetic/domain/entities/value_objects/money_details.dart';
import 'package:cashnetic/domain/entities/value_objects/time_interval.dart';
import 'package:cashnetic/domain/failures/failure.dart';
import 'package:cashnetic/domain/failures/repository_failure.dart';
import 'package:cashnetic/domain/repositories/account_repository.dart';

class MockedAccountRepository implements AccountRepository {
  final List<Account> _accounts = [
    Account(
      id: 1,
      userId: 1,
      name: 'Mocked Account',
      moneyDetails: MoneyDetails(balance: 114, currency: 'RUB'),
      timeInterval: TimeInterval(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ),
  ];

  int _nextId() {
    final usedIds = _accounts.map((a) => a.id).toSet();
    int id = 1;
    while (usedIds.contains(id)) {
      id++;
    }
    return id;
  }

  @override
  Future<Either<Failure, Account>> createAccount(AccountForm form) async {
    try {
      final account = Account(
        id: _nextId(),
        userId: 1,
        name: form.name ?? 'Mocked Account',
        moneyDetails:
            form.moneyDetails ?? MoneyDetails(balance: 0, currency: 'RUB'),
        timeInterval: TimeInterval(
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      _accounts.add(account);
      return right(account);
    } catch (e) {
      return left(RepositoryFailure('Ошибка при создании аккаунта: $e'));
    }
  }

  @override
  Future<Either<Failure, AccountResponse>> getAccountById(int id) async {
    final account = _accounts.where((a) => a.id == id).firstOrNull;
    if (account == null) {
      return left(RepositoryFailure('Аккаунт с id $id не найден'));
    }
    return right(
      AccountResponse(
        id: account.id,
        name: account.name,
        moneyDetails: account.moneyDetails,
        incomeStats: [],
        expenseStats: [],
        timeInterval: account.timeInterval,
      ),
    );
  }

  @override
  Future<Either<Failure, AccountHistory>> getAccountHistory(int id) async {
    final account = _accounts.where((a) => a.id == id).firstOrNull;
    if (account == null) {
      return left(RepositoryFailure('История аккаунта с id $id не найдена'));
    }
    return right(
      AccountHistory(
        accountId: account.id,
        accountName: account.name,
        moneyDetails: account.moneyDetails,
        history: [],
      ),
    );
  }

  @override
  Future<Either<Failure, List<Account>>> getAllAccounts() async {
    return right(List.unmodifiable(_accounts));
  }

  @override
  Future<Either<Failure, AccountForm>> updateAccount(
    int id,
    AccountForm form,
  ) async {
    final index = _accounts.indexWhere((a) => a.id == id);
    if (index == -1) {
      return left(RepositoryFailure('Не удалось обновить: аккаунт не найден'));
    }

    final updated = Account(
      id: id,
      userId: _accounts[index].userId,
      name: form.name ?? _accounts[index].name,
      moneyDetails: form.moneyDetails ?? _accounts[index].moneyDetails,
      timeInterval: TimeInterval(
        createdAt: _accounts[index].timeInterval.createdAt,
        updatedAt: DateTime.now(),
      ),
    );

    _accounts[index] = updated;

    return right(
      AccountForm(name: updated.name, moneyDetails: updated.moneyDetails),
    );
  }

  @override
  Future<void> deleteAccount(int id) async {
    _accounts.removeWhere((a) => a.id == id);
  }
}
