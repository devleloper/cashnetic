import 'package:dartz/dartz.dart';
import 'package:cashnetic/data/mappers/types/try_parse_double.dart';
import 'package:cashnetic/data/models/accout_state/account_state.dart';
import 'package:cashnetic/domain/entities/account_state.dart';
import 'package:cashnetic/domain/failures/failure.dart';

import '../../domain/entities/value_objects/money_details.dart';

extension AccountStateMapper on AccountStateDTO {
  Either<Failure, AccountState> toDomain() {
    final balanceOrFailure = tryParseDouble(balance, 'balance');

    return balanceOrFailure.map(
      (parsedBalance) => AccountState(
        id: this.id,
        name: name,
        moneyDetails: MoneyDetails(balance: parsedBalance, currency: currency),
      ),
    );
  }
}
