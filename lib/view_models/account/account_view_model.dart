import 'package:cashnetic/view_models/shared/transactions_view_model.dart';
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

  Future<void> load() async {
    _loading = true;
    notifyListeners();

    _account = await repo.fetchAccount();
    await _buildDailyPoints();
    _recalculateBalance();

    _loading = false;
    notifyListeners();
  }

  void _recalculateBalance() {
    final totIncome = _dailyPoints.fold<double>(0, (sum, p) => sum + p.income);
    final totExpense = _dailyPoints.fold<double>(
      0,
      (sum, p) => sum + p.expense,
    );
    final newBalance = (_account?.balance ?? 0) + totIncome - totExpense;

    if (_account != null && _account!.balance != newBalance) {
      _account = _account!.copyWith(balance: newBalance);
      repo.updateAccount(_account!);
    }
  }

  Future<void> _buildDailyPoints() async {
    final originalTxns = await transactionsRepo.loadTransactions();
    if (originalTxns.isEmpty) return;

    final txns = List<TransactionModel>.from(originalTxns)
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    final start = DateTime(
      txns.first.dateTime.year,
      txns.first.dateTime.month,
      txns.first.dateTime.day,
    );
    final end = DateTime(
      txns.last.dateTime.year,
      txns.last.dateTime.month,
      txns.last.dateTime.day,
    );

    final days = <DateTime>[];
    for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      days.add(d);
    }

    final map = {for (final d in days) d: DailyBalancePoint(d, 0, 0)};
    for (final t in txns) {
      final d = DateTime(t.dateTime.year, t.dateTime.month, t.dateTime.day);
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

  Future<void> updateBalance(double newBalance) async {
    if (_account == null) return;
    _account = _account!.copyWith(balance: newBalance);
    await repo.updateAccount(_account!);
    await load();
  }

  void updateAccount(AccountModel updated) {
    _account = updated;
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
    notifyListeners();
    await _buildDailyPoints();
    notifyListeners();
  }

  void bindTransactions(TransactionsViewModel txViewModel) {
    txViewModel.addListener(() {
      _buildDailyPoints().then((_) => notifyListeners());
    });
  }
}
