import 'package:flutter/material.dart';
import '../../models/account/account_model.dart';
import '../../models/transactions/transaction_model.dart';
import '../../repositories/account/account_repository.dart';
import '../../repositories/transactions/transactions_repository.dart';

class DailyBalancePoint {
  final DateTime date;
  double income;
  double expense;
  DailyBalancePoint(this.date, this.income, this.expense);
}

class AccountViewModel extends ChangeNotifier {
  final AccountRepository repo;
  final TransactionsRepository transactionsRepo;

  AccountModel? _account;
  bool _loading = true;
  List<DailyBalancePoint> _dailyPoints = [];

  AccountViewModel({required this.repo, required this.transactionsRepo});

  AccountModel? get account => _account;
  bool get loading => _loading;
  List<DailyBalancePoint> get dailyPoints => _dailyPoints;

  double get computedBalance {
    final income = _dailyPoints.fold<double>(0, (sum, p) => sum + p.income);
    final expense = _dailyPoints.fold<double>(0, (sum, p) => sum + p.expense);
    return (_account?.initialBalance ?? 0) + income - expense;
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();

    _account = await repo.fetchAccount();
    await _buildDailyPoints();

    _loading = false;
    notifyListeners();
  }

  Future<void> _buildDailyPoints() async {
    final transactions = await transactionsRepo.loadTransactions();
    if (transactions.isEmpty) {
      _dailyPoints = [];
      return;
    }

    final sorted = List<TransactionModel>.from(transactions)
      ..sort((a, b) => a.transactionDate.compareTo(b.transactionDate));

    final start = DateTime(
      sorted.first.transactionDate.year,
      sorted.first.transactionDate.month,
      sorted.first.transactionDate.day,
    );
    final end = DateTime(
      sorted.last.transactionDate.year,
      sorted.last.transactionDate.month,
      sorted.last.transactionDate.day,
    );

    final days = <DateTime>[];
    for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      days.add(d);
    }

    final map = {for (final d in days) d: DailyBalancePoint(d, 0, 0)};
    for (final t in sorted) {
      final d = DateTime(t.transactionDate.year, t.transactionDate.month, t.transactionDate.day);
      final p = map[d];
      if (p != null) {
        if (t.type == TransactionType.income) {
          p.income += t.amount;
        } else {
          p.expense += t.amount;
        }
      }
    }

    _dailyPoints = days.map((d) => map[d]!).toList();
  }

  Future<void> updateName(String newName) async {
    if (_account == null) return;
    _account = _account!.copyWith(name: newName);
    await repo.updateAccount(_account!);
    notifyListeners();
  }

  Future<void> updateCurrency(String newCurrency) async {
    if (_account == null) return;
    _account = _account!.copyWith(currency: newCurrency);
    await repo.updateAccount(_account!);
    notifyListeners();
  }

  Future<void> updateInitialBalance(double newBalance) async {
    if (_account == null) return;
    _account = _account!.copyWith(initialBalance: newBalance);
    await repo.updateAccount(_account!);
    await load();
  }

  void updateAccount(AccountModel updated) {
    _account = updated;
    notifyListeners();
    load();
  }

  Future<void> updateAccountAndRebuild(AccountModel updated) async {
    _account = updated;
    await repo.updateAccount(updated);
    await load();
  }

  Future<void> updateCurrencyAndRebuild(String cur) async {
    if (_account == null) return;
    _account = _account!.copyWith(currency: cur);
    await repo.updateAccount(_account!);
    await load();
  }

  void bindTransactions(ValueNotifier<List<TransactionModel>> txNotifier) {
    txNotifier.addListener(() {
      _buildDailyPoints().then((_) => notifyListeners());
    });
  }
}
