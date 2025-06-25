import 'value_objects/money_details.dart';
import 'value_objects/time_interval.dart';

class Account {
  final int id;
  final int userId;
  final String name;
  final MoneyDetails moneyDetails;
  final TimeInterval timeInterval;

  Account({
    required this.id,
    required this.userId,
    required this.name,
    required this.moneyDetails,
    required this.timeInterval,
  });

  Account copyWith({
    int? id,
    int? userId,
    String? name,
    MoneyDetails? moneyDetails,
    TimeInterval? timeInterval,
  }) {
    return Account(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      moneyDetails: moneyDetails ?? this.moneyDetails,
      timeInterval: timeInterval ?? this.timeInterval,
    );
  }
}
