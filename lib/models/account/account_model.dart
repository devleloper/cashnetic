class AccountModel {
  final int id;
  final String name;
  final double initialBalance;
  final String currency;

  const AccountModel({
    required this.id,
    required this.name,
    required this.initialBalance,
    required this.currency,
  });

  AccountModel copyWith({
    int? id,
    String? name,
    double? initialBalance,
    String? currency,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      initialBalance: initialBalance ?? this.initialBalance,
      currency: currency ?? this.currency,
    );
  }
}
