export 'view/view.dart';
import 'package:cashnetic/domain/entities/account.dart';
import 'package:cashnetic/domain/entities/value_objects/money_details.dart';
import 'package:cashnetic/domain/entities/value_objects/time_interval.dart';
import 'package:cashnetic/models/account/account_model.dart';

AccountModel accountDomainToModel(Account account) {
  return AccountModel(
    id: account.id,
    name: account.name,
    initialBalance: account.moneyDetails.balance,
    currency: account.moneyDetails.currency,
  );
}

Account accountModelToDomain(
  AccountModel model,
  int userId,
  DateTime createdAt,
  DateTime updatedAt,
) {
  // Для обновления: userId и даты можно брать из текущего аккаунта
  return Account(
    id: model.id,
    userId: userId,
    name: model.name,
    moneyDetails: MoneyDetails(
      balance: model.initialBalance,
      currency: model.currency,
    ),
    timeInterval: TimeInterval(createdAt: createdAt, updatedAt: updatedAt),
  );
}
