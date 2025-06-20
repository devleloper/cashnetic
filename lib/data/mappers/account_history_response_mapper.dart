import 'package:dartz/dartz.dart';
import 'package:cashnetic/data/mappers/account_history_mapper.dart';
import 'package:cashnetic/data/mappers/types/try_parse_double.dart';
import 'package:cashnetic/data/mappers/types/try_parse_nested_list_mapper.dart';
import 'package:cashnetic/data/models/account_history_response/account_history_response.dart';
import 'package:cashnetic/domain/entities/account_history.dart';
import 'package:cashnetic/domain/entities/value_objects/money_details.dart';
import 'package:cashnetic/domain/failures/failure.dart';

extension AccountHistoryResponseMapper on AccountHistoryResponseDTO {
  Either<Failure, AccountHistory> toDomain() {
    final balanceOrFailure = tryParseDouble(currentBalance, 'currentBalance');

    final historyOrFailure = tryParseNestedList(
      history.map((item) => item.toDomain()),
    );

    return balanceOrFailure.flatMap(
      (parsedBalance) => historyOrFailure.map(
        (parsedHistory) => AccountHistory(
          accountId: accountId,
          accountName: accountName,
          moneyDetails: MoneyDetails(
            balance: parsedBalance,
            currency: currency,
          ),
          history: parsedHistory,
        ),
      ),
    );
  }
}
