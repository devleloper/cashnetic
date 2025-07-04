import 'package:cashnetic/domain/entities/account.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashnetic/presentation/features/account/repositories/account_repository.dart';
import 'account_event.dart';
import 'account_state.dart';
import 'package:cashnetic/data/models/account/account.dart';
import 'package:cashnetic/domain/entities/forms/account_form.dart';
import 'package:cashnetic/domain/entities/value_objects/money_details.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'package:cashnetic/di/di.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final AccountRepository accountRepository = getIt<AccountRepository>();

  AccountBloc() : super(AccountLoading()) {
    on<LoadAccount>(_onLoadAccount);
    on<UpdateAccountName>(_onUpdateName);
    on<UpdateAccountCurrency>(_onUpdateCurrency);
    on<UpdateAccountBalance>(_onUpdateBalance);
    on<UpdateAccount>(_onUpdateAccount);
    on<SelectAccount>(_onSelectAccount);
    on<SelectAccounts>(_onSelectAccounts);
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
          emit(AccountError('No accounts'));
          return;
        }
        final selected = accounts.first;
        final dailyPoints = await accountRepository.buildDailyPoints(
          selected.id,
        );
        final computedBalance = accountRepository.computeBalance(
          selected,
          dailyPoints,
        );
        final aggregatedBalances = {
          selected.moneyDetails.currency: selected.moneyDetails.balance,
        };
        final selectedCurrencies = [selected.moneyDetails.currency];
        emit(
          AccountLoaded(
            account: selected,
            dailyPoints: dailyPoints,
            computedBalance: computedBalance,
            accounts: accounts,
            selectedAccountId: selected.id,
            selectedAccountIds: [selected.id],
            aggregatedBalances: aggregatedBalances,
            selectedCurrencies: selectedCurrencies,
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
    final updated = current.copyWith(name: event.newName);
    final result = await accountRepository.updateAccount(
      updated.id,
      accountRepository.toForm(updated),
    );
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
    final updated = current.copyWith(
      moneyDetails: current.moneyDetails.copyWith(currency: event.newCurrency),
    );
    final result = await accountRepository.updateAccount(
      updated.id,
      accountRepository.toForm(updated),
    );
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
    final updated = current.copyWith(
      moneyDetails: current.moneyDetails.copyWith(balance: event.newBalance),
    );
    final result = await accountRepository.updateAccount(
      updated.id,
      accountRepository.toForm(updated),
    );
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
    final result = await accountRepository.updateAccount(
      updated.id,
      accountRepository.toForm(updated),
    );
    result.fold(
      (failure) => emit(AccountError(failure.toString())),
      (_) => add(LoadAccount()),
    );
  }

  Future<void> _onSelectAccount(
    SelectAccount event,
    Emitter<AccountState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AccountLoaded) return;
    final accounts = currentState.accounts;
    final selected = accounts.firstWhere(
      (a) => a.id == event.accountId,
      orElse: () => accounts.first,
    );
    final dailyPoints = await accountRepository.buildDailyPoints(selected.id);
    final computedBalance = accountRepository.computeBalance(
      selected,
      dailyPoints,
    );
    final aggregatedBalances = {
      selected.moneyDetails.currency: selected.moneyDetails.balance,
    };
    final selectedCurrencies = [selected.moneyDetails.currency];
    emit(
      AccountLoaded(
        account: selected,
        dailyPoints: dailyPoints,
        computedBalance: computedBalance,
        accounts: accounts,
        selectedAccountId: selected.id,
        selectedAccountIds: [selected.id],
        aggregatedBalances: aggregatedBalances,
        selectedCurrencies: selectedCurrencies,
      ),
    );
  }

  Future<void> _onSelectAccounts(
    SelectAccounts event,
    Emitter<AccountState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AccountLoaded) return;
    final accounts = currentState.accounts;
    final selectedAccounts = accounts
        .where((a) => event.accountIds.contains(a.id))
        .toList();
    if (selectedAccounts.isEmpty) return;
    // Для каждого счета вычисляем его dailyPoints и computedBalance
    final Map<int, List<DailyBalancePoint>> accountPoints = {};
    final Map<int, double> accountBalances = {};
    final Map<String, double> aggregatedBalances = {};
    final List<String> selectedCurrencies = [];
    for (final acc in selectedAccounts) {
      final points = await accountRepository.buildDailyPoints(acc.id);
      final computed = accountRepository.computeBalance(acc, points);
      accountPoints[acc.id] = points;
      accountBalances[acc.id] = computed;
      // агрегируем по валютам
      final currency = acc.moneyDetails.currency;
      aggregatedBalances[currency] =
          (aggregatedBalances[currency] ?? 0) + computed;
      if (!selectedCurrencies.contains(currency)) {
        selectedCurrencies.add(currency);
      }
    }
    // Для отображения account используем первый выбранный
    final selected = selectedAccounts.first;
    // dailyPoints агрегируем по дням (если нужно для графика)
    List<DailyBalancePoint> aggregatedPoints = [];
    if (accountPoints.isNotEmpty) {
      final anyPoints = accountPoints.values.first;
      aggregatedPoints = List.generate(anyPoints.length, (i) {
        final date = anyPoints[i].date;
        double income = 0;
        double expense = 0;
        for (final points in accountPoints.values) {
          income += points[i].income;
          expense += points[i].expense;
        }
        return DailyBalancePoint(date, income, expense);
      });
    }
    // computedBalance — сумма по всем выбранным счетам
    final computedBalance = accountBalances.values.fold<double>(
      0,
      (a, b) => a + b,
    );
    emit(
      AccountLoaded(
        account: selected,
        dailyPoints: aggregatedPoints,
        computedBalance: computedBalance,
        accounts: accounts,
        selectedAccountId: selected.id,
        selectedAccountIds: event.accountIds,
        aggregatedBalances: aggregatedBalances,
        selectedCurrencies: selectedCurrencies,
      ),
    );
  }
}
