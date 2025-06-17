class Category {
  final int _id;
  final String _name;
  final String _emoji;
  final bool _isIncome;

  Category({
    required int id,
    required String name,
    required String emoji,
    required bool isIncome,
  }) : _id = id,
       _name = name,
       _emoji = emoji,
       _isIncome = isIncome;

  bool get isIncome => _isIncome;

  String get emoji => _emoji;

  String get name => _name;

  int get id => _id;
}
