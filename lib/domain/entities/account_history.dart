import 'account_history_item.dart';
import 'value_objects/money_details.dart';

class AccountHistory {
  final int _accountId;
  final String _accountName;
  final MoneyDetails _moneyDetails;
  final List<AccountHistoryItem> _history;

  AccountHistory({
    required int accountId,
    required String accountName,
    required MoneyDetails moneyDetails,
    required List<AccountHistoryItem> history,
  }) : _accountId = accountId,
       _accountName = accountName,
       _moneyDetails = moneyDetails,
       _history = history;

  List<AccountHistoryItem> get history => _history;

  MoneyDetails get moneyDetails => _moneyDetails;

  String get accountName => _accountName;

  int get accountId => _accountId;
}
