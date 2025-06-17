class TransactionForm {
  final int? _accountId;
  final int? _categoryId;
  final double? _amount;
  final DateTime? _timestamp;
  final String? _comment;

  TransactionForm({
    required int? accountId,
    required int? categoryId,
    required double? amount,
    required DateTime? timestamp,
    required String? comment,
  }) : _accountId = accountId,
       _categoryId = categoryId,
       _amount = amount,
       _timestamp = timestamp,
       _comment = comment;

  String? get comment => _comment;

  DateTime? get timestamp => _timestamp;

  double? get amount => _amount;

  int? get categoryId => _categoryId;

  int? get accountId => _accountId;
}
