import 'package:cashnetic/models/account/account_model.dart';

abstract class AccountRepository {
  Future<AccountModel> fetchAccount();
  Future<void> updateAccount(AccountModel account);
}

class AccountsRepositoryImpl extends AccountRepository {
  AccountModel? _cached;

  @override
  Future<AccountModel> fetchAccount() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _cached ??= AccountModel(
      id: 1,
      name: 'Мой счёт',
      balance: 0,
      currency: '₽',
    );
    return _cached!;
  }

  @override
  Future<void> updateAccount(AccountModel account) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _cached = account;
  }
}
