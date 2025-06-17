class StatItem {
  final int _categoryId;
  final String _categoryName;
  final String _emoji;
  final double _amount;

  StatItem({
    required int categoryId,
    required String categoryName,
    required String emoji,
    required double amount,
  }) : _categoryId = categoryId,
       _categoryName = categoryName,
       _emoji = emoji,
       _amount = amount;

  double get amount => _amount;

  String get emoji => _emoji;

  String get categoryName => _categoryName;

  int get categoryId => _categoryId;
}
