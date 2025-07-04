import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashnetic/presentation/features/account_edit/repositories/account_edit_repository.dart';
import 'account_edit_event.dart';
import 'account_edit_state.dart';
import 'package:cashnetic/di/di.dart';

class AccountEditBloc extends Bloc<AccountEditEvent, AccountEditState> {
  final AccountEditRepository accountEditRepository =
      getIt<AccountEditRepository>();
  AccountEditBloc() : super(AccountEditInitial()) {
    on<AccountEditInitialized>(_onInitialized);
    on<AccountEditNameChanged>(_onNameChanged);
    on<AccountEditBalanceChanged>(_onBalanceChanged);
    on<AccountEditCurrencyChanged>(_onCurrencyChanged);
    on<AccountEditSubmitted>(_onSubmitted);
  }

  void _onInitialized(
    AccountEditInitialized event,
    Emitter<AccountEditState> emit,
  ) {
    emit(
      AccountEditLoaded(
        account: event.account,
        name: event.account.name,
        balance: event.account.moneyDetails.balance.toString(),
        currency: event.account.moneyDetails.currency,
      ),
    );
  }

  void _onNameChanged(
    AccountEditNameChanged event,
    Emitter<AccountEditState> emit,
  ) {
    if (state is! AccountEditLoaded) return;
    final current = state as AccountEditLoaded;
    emit(
      AccountEditLoaded(
        account: current.account,
        name: event.name,
        balance: current.balance,
        currency: current.currency,
      ),
    );
  }

  void _onBalanceChanged(
    AccountEditBalanceChanged event,
    Emitter<AccountEditState> emit,
  ) {
    if (state is! AccountEditLoaded) return;
    final current = state as AccountEditLoaded;
    emit(
      AccountEditLoaded(
        account: current.account,
        name: current.name,
        balance: event.balance,
        currency: current.currency,
      ),
    );
  }

  void _onCurrencyChanged(
    AccountEditCurrencyChanged event,
    Emitter<AccountEditState> emit,
  ) {
    if (state is! AccountEditLoaded) return;
    final current = state as AccountEditLoaded;
    emit(
      AccountEditLoaded(
        account: current.account,
        name: current.name,
        balance: current.balance,
        currency: event.currency,
      ),
    );
  }

  Future<void> _onSubmitted(
    AccountEditSubmitted event,
    Emitter<AccountEditState> emit,
  ) async {
    if (state is! AccountEditLoaded) return;
    final current = state as AccountEditLoaded;
    emit(AccountEditLoading());
    final result = await accountEditRepository.validateAndUpdateAccount(
      account: current.account,
      name: current.name,
      balance: current.balance,
      currency: current.currency,
    );
    result.fold(
      (failure) => emit(AccountEditError(failure.toString())),
      (_) => emit(AccountEditSuccess()),
    );
  }
}
