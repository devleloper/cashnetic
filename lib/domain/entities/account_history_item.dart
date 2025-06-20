import 'account_state.dart';
import 'enums/change_type.dart';
import 'value_objects/time_interval.dart';

class AccountHistoryItem {
  final int _id;
  final int _accountId;
  final ChangeType _changeType;
  final AccountState? _previousState;
  final AccountState _newState;
  final TimeInterval _timeInterval;

  AccountHistoryItem({
    required int id,
    required int accountId,
    required ChangeType changeType,
    required AccountState? previousState,
    required AccountState newState,
    required TimeInterval timeInterval,
  }) : _id = id,
       _accountId = accountId,
       _changeType = changeType,
       _previousState = previousState,
       _newState = newState,
       _timeInterval = timeInterval;

  TimeInterval get timeInterval => _timeInterval;

  AccountState get newState => _newState;

  AccountState? get previousState => _previousState;

  ChangeType get changeType => _changeType;

  int get accountId => _accountId;

  int get id => _id;
}
