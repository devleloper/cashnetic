class Category {
  final int id;
  final String name;
  final String emoji;
  final bool isIncome;
  final String color; // hex-код цвета

  Category({
    required this.id,
    required this.name,
    required this.emoji,
    required this.isIncome,
    required this.color,
  });
}
