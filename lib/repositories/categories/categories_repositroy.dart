import 'package:cashnetic/models/category/category_model.dart';

abstract class CategoriesRepository {
  Future<List<CategoryModel>> fetchAll({bool? isIncome});
  Future<CategoryModel> addCategory({
    required String name,
    String emoji,
    required bool isIncome,
  });

  Future<void> addCategoryModel(CategoryModel category);

  Future<CategoryModel?> updateCategory(CategoryModel category);
  Future<bool> deleteCategory(int categoryId);
}

class CategoriesRepositoryImpl implements CategoriesRepository {
  final List<CategoryModel> _categories = [
    CategoryModel(id: 1, name: 'Продукты', emoji: '🛒', isIncome: false),
    CategoryModel(id: 2, name: 'Зарплата', emoji: '💼', isIncome: true),
    CategoryModel(id: 3, name: 'Транспорт', emoji: '🚌', isIncome: false),
    CategoryModel(id: 4, name: 'Подработка', emoji: '🪙', isIncome: true),
  ];

  int _nextId = 5;

  @override
  Future<List<CategoryModel>> fetchAll({bool? isIncome}) async {
    if (isIncome == null) return List.unmodifiable(_categories);
    return _categories.where((c) => c.isIncome == isIncome).toList();
  }

  @override
  Future<CategoryModel> addCategory({
    required String name,
    String emoji = '💰',
    required bool isIncome,
  }) async {
    final newCat = CategoryModel(
      id: _nextId++,
      name: name,
      emoji: emoji,
      isIncome: isIncome,
    );
    _categories.add(newCat);
    return newCat;
  }

  @override
  Future<void> addCategoryModel(CategoryModel category) async {
    final withId = category.copyWith(id: _nextId++);
    _categories.add(withId);
  }

  @override
  Future<CategoryModel?> updateCategory(CategoryModel category) async {
    final idx = _categories.indexWhere((c) => c.id == category.id);
    if (idx == -1) return null;
    _categories[idx] = category;
    return category;
  }

  @override
  Future<bool> deleteCategory(int categoryId) async {
    final initialLength = _categories.length;
    _categories.removeWhere((c) => c.id == categoryId);
    return _categories.length < initialLength;
  }
}
