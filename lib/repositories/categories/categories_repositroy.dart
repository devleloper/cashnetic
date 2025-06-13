import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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
  static const _storageKey = 'categories_storage';

  final List<CategoryModel> _defaultCategories = const [
    CategoryModel(id: 1, name: 'Продукты', emoji: '🛒', isIncome: false),
    CategoryModel(id: 1, name: 'Ремонт', emoji: '🏠', isIncome: false),
    CategoryModel(id: 1, name: 'Одежда', emoji: '👗', isIncome: false),
    CategoryModel(id: 1, name: 'Электроника', emoji: '📱', isIncome: false),
    CategoryModel(id: 1, name: 'Развлечения', emoji: '🎉', isIncome: false),
    CategoryModel(id: 1, name: 'Образование', emoji: '🎓', isIncome: false),
    CategoryModel(id: 1, name: 'Образование', emoji: '🎓', isIncome: false),
    CategoryModel(id: 1, name: 'Животные', emoji: '🐶', isIncome: false),
    CategoryModel(id: 1, name: 'Здоровье', emoji: '💊', isIncome: false),
    CategoryModel(id: 1, name: 'Подарки', emoji: '🎁', isIncome: false),
    CategoryModel(id: 1, name: 'Спорт', emoji: '🏋️', isIncome: false),
    CategoryModel(id: 3, name: 'Транспорт', emoji: '🚌', isIncome: false),
    CategoryModel(id: 2, name: 'Зарплата', emoji: '💼', isIncome: true),
    CategoryModel(id: 4, name: 'Подработка', emoji: '🪙', isIncome: true),
  ];

  final List<CategoryModel> _categories = [];
  int _nextId = 5;

  Future<void> _loadFromStorage() async {
    if (_categories.isNotEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_storageKey);

    if (rawJson == null) {
      _categories.addAll(_defaultCategories);
      _nextId =
          _defaultCategories.map((c) => c.id).fold(0, (a, b) => a > b ? a : b) +
          1;
      await _saveToStorage();
      return;
    }

    final List<dynamic> decoded = jsonDecode(rawJson);
    final stored = decoded.map((e) => CategoryModel.fromJson(e)).toList();
    _categories.addAll(stored);
    _nextId = _categories.map((c) => c.id).fold(0, (a, b) => a > b ? a : b) + 1;
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_categories.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  @override
  Future<List<CategoryModel>> fetchAll({bool? isIncome}) async {
    await _loadFromStorage();
    if (isIncome == null) return List.unmodifiable(_categories);
    return _categories
        .where((c) => c.isIncome == isIncome)
        .toList(growable: false);
  }

  @override
  Future<CategoryModel> addCategory({
    required String name,
    String emoji = '💰',
    required bool isIncome,
  }) async {
    await _loadFromStorage();

    final newCat = CategoryModel(
      id: _nextId++,
      name: name,
      emoji: emoji,
      isIncome: isIncome,
    );

    _categories.add(newCat);
    await _saveToStorage();
    return newCat;
  }

  @override
  Future<void> addCategoryModel(CategoryModel category) async {
    await _loadFromStorage();

    final withId = category.copyWith(id: _nextId++);
    _categories.add(withId);
    await _saveToStorage();
  }

  @override
  Future<CategoryModel?> updateCategory(CategoryModel category) async {
    await _loadFromStorage();

    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index == -1) return null;

    _categories[index] = category;
    await _saveToStorage();
    return category;
  }

  @override
  Future<bool> deleteCategory(int categoryId) async {
    await _loadFromStorage();

    final initialLen = _categories.length;
    _categories.removeWhere((c) => c.id == categoryId);
    final deleted = _categories.length < initialLen;

    if (deleted) await _saveToStorage();
    return deleted;
  }
}
