import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashnetic/presentation/features/account_add/repositories/account_add_repository.dart';
import 'account_add_event.dart';
import 'account_add_state.dart';
import 'package:cashnetic/di/di.dart';

class AccountAddBloc extends Bloc<AccountAddEvent, AccountAddState> {
  final AccountAddRepository accountAddRepository =
      getIt<AccountAddRepository>();
  AccountAddBloc()
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
    emit(AccountAddLoading());
    final result = await accountAddRepository.validateAndCreateAccount(
      name: current.name,
      balance: current.balance,
      currency: current.currency,
    );
    result.fold(
      (failure) => emit(AccountAddError(failure.toString())),
      (_) => emit(AccountAddSuccess()),
    );
  }
}
