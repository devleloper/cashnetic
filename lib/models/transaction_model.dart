class TransactionModel {
  final int id;
  final String categoryIcon;
  final String categoryTitle;
  final String? comment;
  final double amount;

  TransactionModel({
    required this.id,
    required this.categoryIcon,
    required this.categoryTitle,
    required this.amount,
    this.comment,
  });
}
