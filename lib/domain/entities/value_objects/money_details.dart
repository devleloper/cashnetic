class MoneyDetails {
  final double balance;
  final String currency;

  MoneyDetails({required this.balance, required this.currency});

  MoneyDetails copyWith({double? balance, String? currency}) {
    return MoneyDetails(
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
    );
  }
}
