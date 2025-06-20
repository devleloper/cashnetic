import '../value_objects/money_details.dart';

class AccountForm {
  final String? _name;
  final MoneyDetails? _moneyDetails;

  AccountForm({required String? name, required MoneyDetails? moneyDetails})
    : _name = name,
      _moneyDetails = moneyDetails;

  String? get name => _name;

  MoneyDetails? get moneyDetails => _moneyDetails;
}
