import 'account_history_item.dart';
import 'value_objects/money_details.dart';

class AccountHistory {
  final int accountId;
  final String accountName;
  final MoneyDetails moneyDetails;
  final List<AccountHistoryItem> history;

  AccountHistory({
    required this.accountId,
    required this.accountName,
    required this.moneyDetails,
    required this.history,
  });
}
