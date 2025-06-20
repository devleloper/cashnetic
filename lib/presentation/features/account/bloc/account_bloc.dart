import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashnetic/domain/repositories/account_repository.dart';
import 'package:cashnetic/domain/repositories/transaction_repository.dart';
import 'package:cashnetic/domain/repositories/category_repository.dart';
import 'account_event.dart';
import 'account_state.dart';
import 'package:cashnetic/data/models/account/account.dart';
import 'package:cashnetic/domain/entities/forms/account_form.dart';
import 'package:cashnetic/domain/entities/value_objects/money_details.dart';
import 'package:cashnetic/domain/entities/category.dart';

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
        final acc = accounts.first;
        final account = AccountDTO(
          id: acc.id,
          userId: acc.userId,
          name: acc.name,
          balance: acc.moneyDetails.balance.toString(),
          currency: acc.moneyDetails.currency,
          createdAt: acc.timeInterval.createdAt.toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        );
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
    final updated = current.copyWith(name: event.newName);
    final result = await accountRepository.updateAccount(
      updated.id,
      dtoToForm(updated),
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
    final updated = current.copyWith(currency: event.newCurrency);
    final result = await accountRepository.updateAccount(
      updated.id,
      dtoToForm(updated),
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
    final updated = current.copyWith(balance: event.newBalance.toString());
    final result = await accountRepository.updateAccount(
      updated.id,
      dtoToForm(updated),
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
    final updated = event.updated as AccountDTO;
    final result = await accountRepository.updateAccount(
      updated.id,
      dtoToForm(updated),
    );
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
    final txs = txResult.fold((_) => <dynamic>[], (txs) => txs);
    if (txs.isEmpty) return [];

    // Получаем все категории
    final catResult = await categoryRepository.getAllCategories();
    final categories = catResult.fold((_) => <dynamic>[], (cats) => cats);

    txs.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final days = <DateTime>[];
    for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      days.add(d);
    }
    final map = {for (final d in days) d: DailyBalancePoint(d, 0, 0)};
    for (final t in txs) {
      final d = DateTime(t.timestamp.year, t.timestamp.month, t.timestamp.day);
      // Найти категорию по t.categoryId
      final cat = categories.firstWhere(
        (c) => c.id == t.categoryId,
        orElse: () => Category(
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
    return days.map((d) => map[d]!).toList();
  }

  double _computeBalance(AccountDTO account, List<DailyBalancePoint> points) {
    final income = points.fold<double>(0, (sum, p) => sum + p.income);
    final expense = points.fold<double>(0, (sum, p) => sum + p.expense);
    return double.tryParse(account.balance) ?? 0 + income - expense;
  }

  AccountForm dtoToForm(AccountDTO dto) => AccountForm(
    name: dto.name,
    moneyDetails: MoneyDetails(
      balance: double.tryParse(dto.balance) ?? 0,
      currency: dto.currency,
    ),
  );
}
