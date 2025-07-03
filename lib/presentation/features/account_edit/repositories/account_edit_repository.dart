import 'package:dartz/dartz.dart';
import 'package:cashnetic/domain/entities/account.dart';
import 'package:cashnetic/domain/entities/forms/account_form.dart';
import 'package:cashnetic/domain/entities/value_objects/money_details.dart';
import 'package:cashnetic/domain/failures/failure.dart';
import 'package:cashnetic/domain/failures/repository_failure.dart';
import 'package:cashnetic/presentation/features/account/repositories/account_repository.dart';

abstract interface class AccountEditRepository {
  Future<Either<Failure, Unit>> validateAndUpdateAccount({
    required Account account,
    required String name,
    required String balance,
    required String currency,
  });
}

class AccountEditRepositoryImpl implements AccountEditRepository {
  final AccountRepository accountRepository;
  AccountEditRepositoryImpl(this.accountRepository);

  @override
  Future<Either<Failure, Unit>> validateAndUpdateAccount({
    required Account account,
    required String name,
    required String balance,
    required String currency,
  }) async {
    if (name.trim().isEmpty) {
      return left(RepositoryFailure('Enter account name'));
    }
    final parsedBalance = double.tryParse(balance.replaceAll(',', '.')) ?? 0.0;
    final updated = account.copyWith(
      name: name.trim(),
      moneyDetails: account.moneyDetails.copyWith(
        balance: parsedBalance,
        currency: currency,
      ),
    );
    final result = await accountRepository.updateAccount(
      updated.id,
      AccountForm(name: updated.name, moneyDetails: updated.moneyDetails),
    );
    return result.fold((failure) => left(failure), (_) => right(unit));
  }
}
