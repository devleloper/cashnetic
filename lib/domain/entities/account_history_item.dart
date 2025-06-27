import 'account_state.dart';
import 'enums/change_type.dart';
import 'value_objects/time_interval.dart';

class AccountHistoryItem {
  final int id;
  final int accountId;
  final ChangeType changeType;
  final AccountState? previousState;
  final AccountState newState;
  final TimeInterval timeInterval;

  AccountHistoryItem({
    required this.id,
    required this.accountId,
    required this.changeType,
    required this.previousState,
    required this.newState,
    required this.timeInterval,
  });
}
