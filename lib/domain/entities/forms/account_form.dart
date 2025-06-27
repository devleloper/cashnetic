import '../value_objects/money_details.dart';

class AccountForm {
  final String? name;
  final MoneyDetails? moneyDetails;

  AccountForm({required this.name, required this.moneyDetails});
}
