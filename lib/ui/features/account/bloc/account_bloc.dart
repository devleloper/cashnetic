import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashnetic/domain/repositories/account_repository.dart';
import 'package:cashnetic/domain/repositories/transaction_repository.dart';
import 'package:cashnetic/domain/repositories/category_repository.dart';
import 'package:cashnetic/domain/entities/account.dart';
import 'package:cashnetic/domain/entities/forms/account_form.dart';
import 'package:cashnetic/domain/entities/value_objects/money_details.dart';
import 'package:cashnetic/domain/entities/transaction.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'account_event.dart';
import 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final AccountRepository accountRepository;
  final TransactionRepository transactionRepository;
  final CategoryRepository categoryRepository;

  AccountBloc({
    required this.accountRepository,
    required this.transactionRepository,
    required this.categoryRepository,
  }) : super(AccountLoading()) {
    on<LoadAccount>(_onLoadAccount);
    on<UpdateAccountName>(_onUpdateName);
    on<UpdateAccountCurrency>(_onUpdateCurrency);
    on<UpdateAccountBalance>(_onUpdateBalance);
    on<UpdateAccount>(_onUpdateAccount);
  }

  Future<void> _onLoadAccount(
    LoadAccount event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountLoading());
    final result = await accountRepository.getAllAccounts();
    await result.fold(
      (failure) async => emit(AccountError(failure.toString())),
      (accounts) async {
        if (accounts.isEmpty) {
          emit(AccountError('Нет аккаунтов'));
          return;
        }
        final account = accounts.first;
        final dailyPoints = await _buildDailyPoints(account.id);
        final computedBalance = _computeBalance(account, dailyPoints);
        emit(
          AccountLoaded(
            account: account,
            dailyPoints: dailyPoints,
            computedBalance: computedBalance,
          ),
        );
      },
    );
  }

  Future<void> _onUpdateName(
    UpdateAccountName event,
    Emitter<AccountState> emit,
  ) async {
    if (state is! AccountLoaded) return;
    final current = (state as AccountLoaded).account;
    final form = AccountForm(
      name: event.newName,
      moneyDetails: current.moneyDetails,
    );
    final result = await accountRepository.updateAccount(current.id, form);
    result.fold(
      (failure) => emit(AccountError(failure.toString())),
      (_) => add(LoadAccount()),
    );
  }

  Future<void> _onUpdateCurrency(
    UpdateAccountCurrency event,
    Emitter<AccountState> emit,
  ) async {
    if (state is! AccountLoaded) return;
    final current = (state as AccountLoaded).account;
    final form = AccountForm(
      name: current.name,
      moneyDetails: MoneyDetails(
        balance: current.moneyDetails.balance,
        currency: event.newCurrency,
      ),
    );
    final result = await accountRepository.updateAccount(current.id, form);
    result.fold(
      (failure) => emit(AccountError(failure.toString())),
      (_) => add(LoadAccount()),
    );
  }

  Future<void> _onUpdateBalance(
    UpdateAccountBalance event,
    Emitter<AccountState> emit,
  ) async {
    if (state is! AccountLoaded) return;
    final current = (state as AccountLoaded).account;
    final form = AccountForm(
      name: current.name,
      moneyDetails: MoneyDetails(
        balance: event.newBalance,
        currency: current.moneyDetails.currency,
      ),
    );
    final result = await accountRepository.updateAccount(current.id, form);
    result.fold(
      (failure) => emit(AccountError(failure.toString())),
      (_) => add(LoadAccount()),
    );
  }

  Future<void> _onUpdateAccount(
    UpdateAccount event,
    Emitter<AccountState> emit,
  ) async {
    if (state is! AccountLoaded) return;
    final updated = event.updated as Account;
    final form = AccountForm(
      name: updated.name,
      moneyDetails: updated.moneyDetails,
    );
    final result = await accountRepository.updateAccount(updated.id, form);
    result.fold(
      (failure) => emit(AccountError(failure.toString())),
      (_) => add(LoadAccount()),
    );
  }

  Future<List<DailyBalancePoint>> _buildDailyPoints(int accountId) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0);
    final txResult = await transactionRepository.getTransactionsByPeriod(
      accountId,
      start,
      end,
    );
    final catResult = await categoryRepository.getAllCategories();
    final txs = txResult.fold((_) => <Transaction>[], (txs) => txs);
    final cats = catResult.fold((_) => <Category>[], (cats) => cats);
    if (txs.isEmpty) return [];
    txs.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final days = <DateTime>[];
    for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      days.add(d);
    }
    final map = {for (final d in days) d: DailyBalancePoint(d, 0, 0)};
    for (final t in txs) {
      final d = DateTime(t.timestamp.year, t.timestamp.month, t.timestamp.day);
      final cat = cats.firstWhere(
        (c) => c.id == t.categoryId,
        orElse: () => Category(id: 0, name: '', emoji: '', isIncome: false),
      );
      final p = map[d];
      if (p != null) {
        if (cat.isIncome) {
          map[d] = DailyBalancePoint(d, p.income + t.amount, p.expense);
        } else {
          map[d] = DailyBalancePoint(d, p.income, p.expense + t.amount);
        }
      }
    }
    return days.map((d) => map[d]!).toList();
  }

  double _computeBalance(Account account, List<DailyBalancePoint> points) {
    final income = points.fold<double>(0, (sum, p) => sum + p.income);
    final expense = points.fold<double>(0, (sum, p) => sum + p.expense);
    return account.moneyDetails.balance + income - expense;
  }
}
