import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashnetic/domain/repositories/account_repository.dart';
import 'package:cashnetic/domain/entities/forms/account_form.dart';
import 'package:cashnetic/domain/entities/value_objects/money_details.dart';
import 'account_add_event.dart';
import 'account_add_state.dart';

class AccountAddBloc extends Bloc<AccountAddEvent, AccountAddState> {
  final AccountRepository accountRepository;
  AccountAddBloc({required this.accountRepository})
    : super(const AccountAddLoaded(name: '', balance: '', currency: '₽')) {
    on<AccountAddNameChanged>(_onNameChanged);
    on<AccountAddBalanceChanged>(_onBalanceChanged);
    on<AccountAddCurrencyChanged>(_onCurrencyChanged);
    on<AccountAddSubmitted>(_onSubmitted);
  }

  void _onNameChanged(
    AccountAddNameChanged event,
    Emitter<AccountAddState> emit,
  ) {
    if (state is! AccountAddLoaded) return;
    final current = state as AccountAddLoaded;
    emit(
      AccountAddLoaded(
        name: event.name,
        balance: current.balance,
        currency: current.currency,
      ),
    );
  }

  void _onBalanceChanged(
    AccountAddBalanceChanged event,
    Emitter<AccountAddState> emit,
  ) {
    if (state is! AccountAddLoaded) return;
    final current = state as AccountAddLoaded;
    emit(
      AccountAddLoaded(
        name: current.name,
        balance: event.balance,
        currency: current.currency,
      ),
    );
  }

  void _onCurrencyChanged(
    AccountAddCurrencyChanged event,
    Emitter<AccountAddState> emit,
  ) {
    if (state is! AccountAddLoaded) return;
    final current = state as AccountAddLoaded;
    emit(
      AccountAddLoaded(
        name: current.name,
        balance: current.balance,
        currency: event.currency,
      ),
    );
  }

  Future<void> _onSubmitted(
    AccountAddSubmitted event,
    Emitter<AccountAddState> emit,
  ) async {
    if (state is! AccountAddLoaded) return;
    final current = state as AccountAddLoaded;
    if (current.name.trim().isEmpty) {
      emit(const AccountAddError('Введите название счета'));
      return;
    }
    final balance =
        double.tryParse(current.balance.replaceAll(',', '.')) ?? 0.0;
    emit(AccountAddLoading());
    final result = await accountRepository.createAccount(
      AccountForm(
        name: current.name.trim(),
        moneyDetails: MoneyDetails(
          balance: balance,
          currency: current.currency,
        ),
      ),
    );
    result.fold(
      (failure) => emit(AccountAddError(failure.toString())),
      (_) => emit(AccountAddSuccess()),
    );
  }
}
