class Category {
  final int _id;
  final String _name;
  final String _emoji;
  final bool _isIncome;
  final String _color; // hex-код цвета

  Category({
    required int id,
    required String name,
    required String emoji,
    required bool isIncome,
    required String color,
  }) : _id = id,
       _name = name,
       _emoji = emoji,
       _isIncome = isIncome,
       _color = color;

  bool get isIncome => _isIncome;

  String get emoji => _emoji;

  String get name => _name;

  int get id => _id;

  String get color => _color;
}
