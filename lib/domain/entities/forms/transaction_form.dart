class TransactionForm {
  final int? accountId;
  final int? categoryId;
  final double? amount;
  final DateTime? timestamp;
  final String? comment;

  TransactionForm({
    required this.accountId,
    required this.categoryId,
    required this.amount,
    required this.timestamp,
    required this.comment,
  });
}
