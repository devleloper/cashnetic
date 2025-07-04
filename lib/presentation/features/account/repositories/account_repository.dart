import 'package:dartz/dartz.dart';
import 'package:cashnetic/domain/entities/account.dart';
import 'package:cashnetic/domain/entities/account_history.dart';
import 'package:cashnetic/domain/entities/account_response.dart';
import 'package:cashnetic/domain/entities/forms/account_form.dart';
import 'package:cashnetic/domain/failures/failure.dart';
import '../bloc/account_state.dart';
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
import 'account_repository.dart';
import 'package:cashnetic/presentation/features/account/bloc/account_state.dart';
import 'package:cashnetic/data/models/account/account.dart';
import 'package:cashnetic/presentation/features/transactions/repositories/transactions_repository.dart';
import 'package:cashnetic/domain/entities/transaction.dart';

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

  // Business logic methods
  Future<List<DailyBalancePoint>> buildDailyPoints(int accountId);
  double computeBalance(Account account, List<DailyBalancePoint> points);
  AccountForm toForm(Account account);
  // You may add more as needed for aggregation, etc.
}

class AccountRepositoryImpl implements AccountRepository {
  final db.AppDatabase dbInstance;
  final TransactionsRepository transactionsRepository;

  AccountRepositoryImpl(this.dbInstance, this.transactionsRepository);

  @override
  Future<Either<Failure, List<domain.Account>>> getAllAccounts() async {
    try {
      final data = await dbInstance.getAllAccounts();
      return Right(data.map((e) => e.toDomain()).toList());
    } catch (e) {
      return Left(RepositoryFailure(e.toString()));
    }
  }

  @override
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

  @override
  Future<Either<Failure, AccountResponse>> getAccountById(int id) async {
    try {
      final acc = await dbInstance.getAccountById(id);
      if (acc == null) return Left(RepositoryFailure('Account not found'));
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

  @override
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

  @override
  Future<Either<Failure, AccountHistory>> getAccountHistory(int id) async {
    return Left(RepositoryFailure('Not implemented'));
  }

  @override
  Future<void> deleteAccount(int id) async {
    await dbInstance.deleteAccount(id);
  }

  @override
  Future<List<DailyBalancePoint>> buildDailyPoints(int accountId) async {
    // Получаем все транзакции по счету за все время
    final txs = await transactionsRepository.getTransactions(
      accountId: accountId,
      from: DateTime(2000), // или любая минимальная дата
      to: DateTime.now().add(const Duration(days: 3650)), // запас на будущее
    );
    if (txs.isEmpty) return [];

    // Получаем все категории
    final categories = await dbInstance.getAllCategories();

    // Собираем уникальные дни
    final dates = txs
        .map(
          (t) => DateTime(t.timestamp.year, t.timestamp.month, t.timestamp.day),
        )
        .toSet()
        .toList();
    dates.sort((a, b) => a.compareTo(b));
    final map = {for (final d in dates) d: DailyBalancePoint(d, 0, 0)};
    for (final t in txs) {
      final d = DateTime(t.timestamp.year, t.timestamp.month, t.timestamp.day);
      // Найти категорию по t.categoryId
      final cat = categories.firstWhere(
        (c) => c.id == t.categoryId,
        orElse: () => db.Category(
          id: 0,
          name: '',
          emoji: '',
          isIncome: false,
          color: '#E0E0E0',
        ),
      );
      final isIncome = cat.isIncome;
      final p = map[d];
      if (p != null) {
        if (isIncome) {
          map[d] = DailyBalancePoint(d, p.income + t.amount, p.expense);
        } else {
          map[d] = DailyBalancePoint(d, p.income, p.expense + t.amount);
        }
      }
    }
    return dates.map((d) => map[d]!).toList();
  }

  @override
  double computeBalance(
    domain.Account account,
    List<DailyBalancePoint> points,
  ) {
    final income = points.fold<double>(0, (sum, p) => sum + p.income);
    final expense = points.fold<double>(0, (sum, p) => sum + p.expense);
    final initialBalance = account.moneyDetails.balance;
    // Остаток = начальный баланс + доходы - расходы
    return initialBalance + income - expense;
  }

  @override
  AccountForm toForm(domain.Account account) =>
      AccountForm(name: account.name, moneyDetails: account.moneyDetails);
}
