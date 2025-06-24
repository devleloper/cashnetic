import 'stat_item.dart';
import 'value_objects/money_details.dart';
import 'value_objects/time_interval.dart';

class AccountResponse {
  final int id;
  final String name;
  final MoneyDetails moneyDetails;
  final List<StatItem> incomeStats;
  final List<StatItem> expenseStats;
  final TimeInterval timeInterval;

  AccountResponse({
    required this.id,
    required this.name,
    required this.moneyDetails,
    required this.incomeStats,
    required this.expenseStats,
    required this.timeInterval,
  });
}
