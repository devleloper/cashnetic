import 'package:dartz/dartz.dart';
import 'package:cashnetic/data/mappers/types/try_parse_datetime.dart';
import 'package:cashnetic/data/mappers/types/try_parse_double.dart';
import 'package:cashnetic/data/models/account/account.dart';
import 'package:cashnetic/domain/entities/account.dart';
import 'package:cashnetic/domain/entities/value_objects/money_details.dart';
import 'package:cashnetic/domain/entities/value_objects/time_interval.dart';
import 'package:cashnetic/domain/failures/failure.dart';

extension AccountMapper on AccountDTO {
  Either<Failure, Account> toDomain() {
    final balanceOrFailure = tryParseDouble(balance, 'balance');
    final createdAtOrFailure = tryParseDateTime(createdAt, 'createdAt');
    final updatedAtOrFailure = tryParseDateTime(updatedAt, 'updatedAt');

    return balanceOrFailure.flatMap(
      (parsedBalance) => createdAtOrFailure.flatMap(
        (parsedCreatedAt) => updatedAtOrFailure.map(
          (parsedUpdatedAt) => Account(
            id: this.id,
            userId: userId,
            name: name,
            moneyDetails: MoneyDetails(
              balance: parsedBalance,
              currency: currency,
            ),
            timeInterval: TimeInterval(
              createdAt: parsedCreatedAt,
              updatedAt: parsedUpdatedAt,
            ),
          ),
        ),
      ),
    );
  }
}
