import 'package:dartz/dartz.dart';
import 'package:cashnetic/data/mappers/types/try_parse_datetime.dart';
import 'package:cashnetic/data/mappers/types/try_parse_double.dart';
import 'package:cashnetic/data/models/account/account.dart';
import 'package:cashnetic/domain/entities/account.dart' as domain;
import 'package:cashnetic/domain/entities/value_objects/money_details.dart';
import 'package:cashnetic/domain/entities/value_objects/time_interval.dart';
import 'package:cashnetic/domain/failures/failure.dart';
import 'package:cashnetic/data/database.dart' as db;

extension AccountMapper on AccountDTO {
  Either<Failure, domain.Account> toDomain() {
    final balanceOrFailure = tryParseDouble(balance, 'balance');
    final createdAtOrFailure = tryParseDateTime(createdAt, 'createdAt');
    final updatedAtOrFailure = tryParseDateTime(updatedAt, 'updatedAt');

    return balanceOrFailure.flatMap(
      (parsedBalance) => createdAtOrFailure.flatMap(
        (parsedCreatedAt) => updatedAtOrFailure.map(
          (parsedUpdatedAt) => domain.Account(
            id: this.id,
            clientId: this.clientId,
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

extension DbAccountMapper on db.Account {
  domain.Account toDomain() {
    return domain.Account(
      id: this.id,
      clientId: this.clientId,
      userId: 0,
      name: this.name,
      moneyDetails: MoneyDetails(
        balance: this.balance,
        currency: this.currency,
      ),
      timeInterval: TimeInterval(
        createdAt: this.createdAt,
        updatedAt: this.updatedAt,
      ),
    );
  }
}
