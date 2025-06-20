import 'value_objects/money_details.dart';
import 'value_objects/time_interval.dart';

class Account {
  final int _id;
  final int _userId;
  final String _name;
  final MoneyDetails _moneyDetails;
  final TimeInterval _timeInterval;

  Account({
    required int id,
    required int userId,
    required String name,
    required MoneyDetails moneyDetails,
    required TimeInterval timeInterval,
  }) : _id = id,
       _userId = userId,
       _name = name,
       _moneyDetails = moneyDetails,
       _timeInterval = timeInterval;

  TimeInterval get timeInterval => _timeInterval;

  MoneyDetails get moneyDetails => _moneyDetails;

  String get name => _name;

  int get userId => _userId;

  int get id => _id;
}
