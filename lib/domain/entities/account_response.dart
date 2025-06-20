import 'stat_item.dart';
import 'value_objects/money_details.dart';
import 'value_objects/time_interval.dart';

class AccountResponse {
  final int _id;
  final String _name;
  final MoneyDetails _moneyDetails;
  final List<StatItem> _incomeStats;
  final List<StatItem> _expenseStats;
  final TimeInterval _timeInterval;

  AccountResponse({
    required int id,
    required String name,
    required MoneyDetails moneyDetails,
    required List<StatItem> incomeStats,
    required List<StatItem> expenseStats,
    required TimeInterval timeInterval,
  }) : _id = id,
       _name = name,
       _moneyDetails = moneyDetails,
       _incomeStats = incomeStats,
       _expenseStats = expenseStats,
       _timeInterval = timeInterval;

  TimeInterval get timeInterval => _timeInterval;

  List<StatItem> get expenseStats => _expenseStats;

  List<StatItem> get incomeStats => _incomeStats;

  MoneyDetails get moneyDetails => _moneyDetails;

  String get name => _name;

  int get id => _id;
}
