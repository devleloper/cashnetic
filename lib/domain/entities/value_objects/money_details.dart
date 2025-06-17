class MoneyDetails {
  final double _balance;
  final String _currency;

  MoneyDetails({required double balance, required String currency})
    : _balance = balance,
      _currency = currency;

  double get balance => _balance;

  String get currency => _currency;
}
