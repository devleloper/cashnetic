import 'value_objects/money_details.dart';

class AccountState {
  final int _id;
  final String _name;
  final MoneyDetails _moneyDetails;

  AccountState({
    required int id,
    required String name,
    required MoneyDetails moneyDetails,
  }) : _id = id,
       _name = name,
       _moneyDetails = moneyDetails;

  MoneyDetails get moneyDetails => _moneyDetails;

  String get name => _name;

  int get id => _id;
}
