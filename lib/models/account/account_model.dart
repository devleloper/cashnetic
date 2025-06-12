class AccountModel {
  final int id;
  final String name;
  final double balance;
  final String currency;

  AccountModel({
    required this.id,
    required this.name,
    required this.balance,
    required this.currency,
  });

  AccountModel copyWith({
    int? id,
    String? name,
    double? balance,
    String? currency,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
    );
  }
}
