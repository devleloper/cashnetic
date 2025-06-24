import 'value_objects/money_details.dart';

class AccountState {
  final int id;
  final String name;
  final MoneyDetails moneyDetails;

  AccountState({
    required this.id,
    required this.name,
    required this.moneyDetails,
  });
}
