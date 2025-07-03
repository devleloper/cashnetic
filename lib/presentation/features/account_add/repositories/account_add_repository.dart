import 'package:dartz/dartz.dart';
import 'package:cashnetic/domain/entities/forms/account_form.dart';
import 'package:cashnetic/domain/entities/value_objects/money_details.dart';
import 'package:cashnetic/domain/failures/failure.dart';
import 'package:cashnetic/domain/failures/repository_failure.dart';
import 'package:cashnetic/presentation/features/account/repositories/account_repository.dart';

abstract interface class AccountAddRepository {
  Future<Either<Failure, Unit>> validateAndCreateAccount({
    required String name,
    required String balance,
    required String currency,
  });
}

class AccountAddRepositoryImpl implements AccountAddRepository {
  final AccountRepository accountRepository;
  AccountAddRepositoryImpl(this.accountRepository);

  @override
  Future<Either<Failure, Unit>> validateAndCreateAccount({
    required String name,
    required String balance,
    required String currency,
  }) async {
    if (name.trim().isEmpty) {
      return left(RepositoryFailure('Enter account name'));
    }
    final parsedBalance = double.tryParse(balance.replaceAll(',', '.')) ?? 0.0;
    final result = await accountRepository.createAccount(
      AccountForm(
        name: name.trim(),
        moneyDetails: MoneyDetails(balance: parsedBalance, currency: currency),
      ),
    );
    return result.fold((failure) => left(failure), (_) => right(unit));
  }
}
