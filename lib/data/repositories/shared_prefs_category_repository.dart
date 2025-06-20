import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cashnetic/domain/repositories/category_repository.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'package:cashnetic/domain/failures/failure.dart';
import 'package:cashnetic/domain/failures/repository_failure.dart';
import 'package:cashnetic/domain/entities/transaction.dart';

class SharedPrefsCategoryRepository implements CategoryRepository {
  static const _storageKey = 'categories_storage';

  final List<Category> _defaultCategories = [
    Category(
      id: 1,
      name: 'Продукты',
      emoji: '🛒',
      isIncome: false,
      color: '#4CAF50',
    ),
    Category(
      id: 2,
      name: 'Ремонт',
      emoji: '🏠',
      isIncome: false,
      color: '#FF9800',
    ),
    Category(
      id: 3,
      name: 'Одежда',
      emoji: '👗',
      isIncome: false,
      color: '#9C27B0',
    ),
    Category(
      id: 4,
      name: 'Электроника',
      emoji: '📱',
      isIncome: false,
      color: '#2196F3',
    ),
    Category(
      id: 5,
      name: 'Развлечения',
      emoji: '🎉',
      isIncome: false,
      color: '#E91E63',
    ),
    Category(
      id: 6,
      name: 'Образование',
      emoji: '🎓',
      isIncome: false,
      color: '#3F51B5',
    ),
    Category(
      id: 7,
      name: 'Животные',
      emoji: '🐶',
      isIncome: false,
      color: '#795548',
    ),
    Category(
      id: 8,
      name: 'Здоровье',
      emoji: '💊',
      isIncome: false,
      color: '#F44336',
    ),
    Category(
      id: 9,
      name: 'Подарки',
      emoji: '🎁',
      isIncome: false,
      color: '#FF5722',
    ),
    Category(
      id: 10,
      name: 'Спорт',
      emoji: '🏋️',
      isIncome: false,
      color: '#00BCD4',
    ),
    Category(
      id: 11,
      name: 'Транспорт',
      emoji: '🚌',
      isIncome: false,
      color: '#607D8B',
    ),
    Category(
      id: 12,
      name: 'Зарплата',
      emoji: '💼',
      isIncome: true,
      color: '#8BC34A',
    ),
    Category(
      id: 13,
      name: 'Подработка',
      emoji: '🪙',
      isIncome: true,
      color: '#CDDC39',
    ),
  ];

  final List<Category> _categories = [];
  int _nextId = 14;

  Future<void> _loadFromStorage() async {
    if (_categories.isNotEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString(_storageKey);

      if (rawJson == null) {
        _categories.addAll(_defaultCategories);
        _nextId =
            _defaultCategories
                .map((c) => c.id)
                .fold(0, (a, b) => a > b ? a : b) +
            1;
        await _saveToStorage();
        return;
      }

      final List<dynamic> decoded = jsonDecode(rawJson);
      final stored = decoded.map((e) => _categoryFromJson(e)).toList();
      _categories.addAll(stored);
      _nextId =
          _categories.map((c) => c.id).fold(0, (a, b) => a > b ? a : b) + 1;
    } catch (e) {
      // Если произошла ошибка при загрузке, используем дефолтные категории
      _categories.clear();
      _categories.addAll(_defaultCategories);
      _nextId =
          _defaultCategories.map((c) => c.id).fold(0, (a, b) => a > b ? a : b) +
          1;
      await _saveToStorage();
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(
        _categories.map((e) => _categoryToJson(e)).toList(),
      );
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      // Игнорируем ошибки сохранения
    }
  }

  Map<String, dynamic> _categoryToJson(Category category) {
    return {
      'id': category.id,
      'name': category.name,
      'emoji': category.emoji,
      'isIncome': category.isIncome,
      'color': category.color,
    };
  }

  Category _categoryFromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      isIncome: json['isIncome'] as bool,
      color: json['color'] as String,
    );
  }

  @override
  Future<Either<Failure, List<Category>>> getAllCategories() async {
    try {
      await _loadFromStorage();
      return Right(List.unmodifiable(_categories));
    } catch (e) {
      return Left(RepositoryFailure('Ошибка при загрузке категорий: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getCategoriesByIsIncome(
    bool isIncome,
  ) async {
    try {
      await _loadFromStorage();
      final filtered = _categories
          .where((c) => c.isIncome == isIncome)
          .toList(growable: false);
      return Right(filtered);
    } catch (e) {
      return Left(RepositoryFailure('Ошибка при загрузке категорий: $e'));
    }
  }

  // Дополнительные методы для работы с категориями
  Future<Either<Failure, Category>> addCategory({
    required String name,
    String emoji = '💰',
    required bool isIncome,
    String color = '#E0E0E0',
  }) async {
    try {
      await _loadFromStorage();

      final newCat = Category(
        id: _nextId++,
        name: name,
        emoji: emoji,
        isIncome: isIncome,
        color: color,
      );

      _categories.add(newCat);
      await _saveToStorage();
      return Right(newCat);
    } catch (e) {
      return Left(RepositoryFailure('Ошибка при добавлении категории: $e'));
    }
  }

  Future<Either<Failure, Category?>> updateCategory(Category category) async {
    try {
      await _loadFromStorage();

      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index == -1) return Right(null);

      _categories[index] = category;
      await _saveToStorage();
      return Right(category);
    } catch (e) {
      return Left(RepositoryFailure('Ошибка при обновлении категории: $e'));
    }
  }

  Future<Either<Failure, bool>> deleteCategory(int categoryId) async {
    try {
      await _loadFromStorage();

      final initialLen = _categories.length;
      _categories.removeWhere((c) => c.id == categoryId);
      final deleted = _categories.length < initialLen;

      if (deleted) await _saveToStorage();
      return Right(deleted);
    } catch (e) {
      return Left(RepositoryFailure('Ошибка при удалении категории: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteCategoryIfUnused(
    int categoryId,
    List<dynamic> allTransactions,
  ) async {
    try {
      await _loadFromStorage();
      final used = allTransactions.any((t) => t.categoryId == categoryId);
      if (used) return Right(false);
      return await deleteCategory(categoryId);
    } catch (e) {
      return Left(
        RepositoryFailure('Ошибка при проверке и удалении категории: $e'),
      );
    }
  }
}
