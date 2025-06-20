import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cashnetic/domain/repositories/account_repository.dart';
import 'package:cashnetic/domain/entities/account.dart';
import 'package:cashnetic/domain/entities/account_history.dart';
import 'package:cashnetic/domain/entities/account_response.dart';
import 'package:cashnetic/domain/entities/forms/account_form.dart';
import 'package:cashnetic/domain/entities/value_objects/money_details.dart';
import 'package:cashnetic/domain/entities/value_objects/time_interval.dart';
import 'package:cashnetic/domain/failures/failure.dart';
import 'package:cashnetic/domain/failures/repository_failure.dart';

class SharedPrefsAccountRepository implements AccountRepository {
  static const _storageKey = 'accounts_storage';
  static const _historyStorageKey = 'account_history_storage';

  final List<Account> _accounts = [];
  int _nextId = 1;

  Future<void> _loadFromStorage() async {
    if (_accounts.isNotEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString(_storageKey);

      if (rawJson == null) {
        // Создаём дефолтный аккаунт
        final defaultAccount = Account(
          id: 1,
          userId: 1,
          name: 'Основной счёт',
          moneyDetails: MoneyDetails(balance: 0.0, currency: '₽'),
          timeInterval: TimeInterval(
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        _accounts.add(defaultAccount);
        _nextId = 2;
        await _saveToStorage();
        return;
      }

      final List<dynamic> decoded = jsonDecode(rawJson);
      final stored = decoded.map((e) => _accountFromJson(e)).toList();
      _accounts.addAll(stored);
      _nextId = _accounts.map((a) => a.id).fold(0, (a, b) => a > b ? a : b) + 1;
    } catch (e) {
      // Если произошла ошибка при загрузке, создаём дефолтный аккаунт
      _accounts.clear();
      final defaultAccount = Account(
        id: 1,
        userId: 1,
        name: 'Основной счёт',
        moneyDetails: MoneyDetails(balance: 0.0, currency: '₽'),
        timeInterval: TimeInterval(
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      _accounts.add(defaultAccount);
      _nextId = 2;
      await _saveToStorage();
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(
        _accounts.map((e) => _accountToJson(e)).toList(),
      );
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      // Игнорируем ошибки сохранения
    }
  }

  Map<String, dynamic> _accountToJson(Account account) {
    return {
      'id': account.id,
      'userId': account.userId,
      'name': account.name,
      'balance': account.moneyDetails.balance,
      'currency': account.moneyDetails.currency,
      'createdAt': account.timeInterval.createdAt.toIso8601String(),
      'updatedAt': account.timeInterval.updatedAt.toIso8601String(),
    };
  }

  Account _accountFromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as int,
      userId: json['userId'] as int,
      name: json['name'] as String,
      moneyDetails: MoneyDetails(
        balance: (json['balance'] as num).toDouble(),
        currency: json['currency'] as String,
      ),
      timeInterval: TimeInterval(
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      ),
    );
  }

  @override
  Future<Either<Failure, List<Account>>> getAllAccounts() async {
    try {
      await _loadFromStorage();
      return Right(List.unmodifiable(_accounts));
    } catch (e) {
      return Left(RepositoryFailure('Ошибка при загрузке аккаунтов: $e'));
    }
  }

  @override
  Future<Either<Failure, Account>> createAccount(AccountForm account) async {
    try {
      await _loadFromStorage();

      final newAccount = Account(
        id: _nextId++,
        userId: 1, // TODO: получить реальный userId
        name: account.name ?? 'Новый счёт',
        moneyDetails:
            account.moneyDetails ?? MoneyDetails(balance: 0.0, currency: '₽'),
        timeInterval: TimeInterval(
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      _accounts.add(newAccount);
      await _saveToStorage();
      return Right(newAccount);
    } catch (e) {
      return Left(RepositoryFailure('Ошибка при создании аккаунта: $e'));
    }
  }

  @override
  Future<Either<Failure, AccountResponse>> getAccountById(int id) async {
    try {
      await _loadFromStorage();

      final account = _accounts.firstWhere((a) => a.id == id);

      // Создаём AccountResponse с базовой информацией
      final accountResponse = AccountResponse(
        id: account.id,
        name: account.name,
        moneyDetails: account.moneyDetails,
        incomeStats: [],
        expenseStats: [],
        timeInterval: account.timeInterval,
      );

      return Right(accountResponse);
    } catch (e) {
      return Left(RepositoryFailure('Ошибка при получении аккаунта: $e'));
    }
  }

  @override
  Future<Either<Failure, AccountForm>> updateAccount(
    int id,
    AccountForm account,
  ) async {
    try {
      await _loadFromStorage();

      final index = _accounts.indexWhere((a) => a.id == id);
      if (index == -1) {
        return Left(RepositoryFailure('Аккаунт не найден'));
      }

      final currentAccount = _accounts[index];
      final updatedAccount = Account(
        id: id,
        userId: currentAccount.userId,
        name: account.name ?? currentAccount.name,
        moneyDetails: account.moneyDetails ?? currentAccount.moneyDetails,
        timeInterval: TimeInterval(
          createdAt: currentAccount.timeInterval.createdAt,
          updatedAt: DateTime.now(),
        ),
      );

      _accounts[index] = updatedAccount;
      await _saveToStorage();

      return Right(account);
    } catch (e) {
      return Left(RepositoryFailure('Ошибка при обновлении аккаунта: $e'));
    }
  }

  @override
  Future<Either<Failure, AccountHistory>> getAccountHistory(int id) async {
    try {
      await _loadFromStorage();

      // Проверяем, что аккаунт существует
      final account = _accounts.firstWhere((a) => a.id == id);

      // Создаём пустую историю (в реальном приложении здесь была бы логика загрузки истории)
      final history = AccountHistory(
        accountId: id,
        accountName: account.name,
        moneyDetails: account.moneyDetails,
        history: [],
      );

      return Right(history);
    } catch (e) {
      return Left(
        RepositoryFailure('Ошибка при получении истории аккаунта: $e'),
      );
    }
  }
}
