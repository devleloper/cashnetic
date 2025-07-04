import 'package:cashnetic/data/database.dart' as db;
import 'package:cashnetic/domain/entities/category.dart' as domain;
import 'package:cashnetic/domain/failures/failure.dart';
import 'package:cashnetic/domain/failures/repository_failure.dart';
import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:cashnetic/data/mappers/category_mapper.dart';
import 'package:flutter/foundation.dart';

class DriftCategoryRepository {
  final db.AppDatabase dbInstance;

  DriftCategoryRepository(this.dbInstance);

  Future<void> _initDefaultCategories() async {
    debugPrint('[DriftCategoryRepository] ENTER _initDefaultCategories');
    final existing = await dbInstance.getAllCategories();
    debugPrint(
      '[DriftCategoryRepository] Existing categories count: ${existing.length}',
    );
    if (existing.isNotEmpty) {
      debugPrint('[DriftCategoryRepository] Existing categories:');
      for (final cat in existing) {
        debugPrint(
          '  - id: ${cat.id}, name: ${cat.name}, isIncome: ${cat.isIncome}',
        );
      }
    }
    final defaults = [
      {
        'name': 'Продукты',
        'emoji': '🛒',
        'isIncome': false,
        'color': '#4CAF50',
      },
      {'name': 'Ремонт', 'emoji': '🏠', 'isIncome': false, 'color': '#FF9800'},
      {'name': 'Одежда', 'emoji': '👗', 'isIncome': false, 'color': '#9C27B0'},
      {
        'name': 'Электроника',
        'emoji': '📱',
        'isIncome': false,
        'color': '#2196F3',
      },
      {
        'name': 'Развлечения',
        'emoji': '🎉',
        'isIncome': false,
        'color': '#E91E63',
      },
      {
        'name': 'Образование',
        'emoji': '🎓',
        'isIncome': false,
        'color': '#3F51B5',
      },
      {
        'name': 'Животные',
        'emoji': '🐶',
        'isIncome': false,
        'color': '#795548',
      },
      {
        'name': 'Здоровье',
        'emoji': '💊',
        'isIncome': false,
        'color': '#F44336',
      },
      {'name': 'Подарки', 'emoji': '🎁', 'isIncome': false, 'color': '#FF5722'},
      {'name': 'Спорт', 'emoji': '🏋️', 'isIncome': false, 'color': '#00BCD4'},
      {
        'name': 'Транспорт',
        'emoji': '🚌',
        'isIncome': false,
        'color': '#607D8B',
      },
      {'name': 'Зарплата', 'emoji': '💼', 'isIncome': true, 'color': '#8BC34A'},
      {
        'name': 'Подработка',
        'emoji': '🪙',
        'isIncome': true,
        'color': '#CDDC39',
      },
    ];
    for (final cat in defaults) {
      final alreadyExists = existing.any(
        (e) => e.name == cat['name'] && e.isIncome == cat['isIncome'],
      );
      if (!alreadyExists) {
        debugPrint(
          '[DriftCategoryRepository] Adding default category: name=${cat['name']}, isIncome=${cat['isIncome']}',
        );
        await dbInstance.insertCategory(
          db.CategoriesCompanion(
            name: Value(cat['name'] as String),
            emoji: Value(cat['emoji'] as String),
            isIncome: Value(cat['isIncome'] as bool),
            color: Value(cat['color'] as String),
          ),
        );
      } else {
        debugPrint(
          '[DriftCategoryRepository] Default category already exists: name=${cat['name']}, isIncome=${cat['isIncome']}',
        );
      }
    }
    debugPrint('[DriftCategoryRepository] EXIT _initDefaultCategories');
  }

  Future<Either<Failure, List<domain.Category>>> getAllCategories() async {
    debugPrint('[DriftCategoryRepository] ENTER getAllCategories');
    try {
      await _initDefaultCategories();
      final data = await dbInstance.getAllCategories();
      debugPrint(
        '[DriftCategoryRepository] Categories after init: count=${data.length}',
      );
      for (final cat in data) {
        debugPrint(
          '  - id: ${cat.id}, name: ${cat.name}, isIncome: ${cat.isIncome}',
        );
      }
      debugPrint('[DriftCategoryRepository] EXIT getAllCategories');
      return Right(data.map((e) => e.toDomain()).toList());
    } catch (e) {
      debugPrint(
        '[DriftCategoryRepository] ERROR in getAllCategories: ${e.toString()}',
      );
      return Left(RepositoryFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<domain.Category>>> getCategoriesByIsIncome(
    bool isIncome,
  ) async {
    try {
      await _initDefaultCategories();
      final data = await dbInstance.getAllCategories();
      final filtered = data
          .where((e) => e.isIncome == isIncome)
          .map((e) => e.toDomain())
          .toList();
      return Right(filtered);
    } catch (e) {
      return Left(RepositoryFailure(e.toString()));
    }
  }

  Future<Either<Failure, domain.Category>> addCategory({
    required String name,
    String emoji = '💰',
    required bool isIncome,
    String color = '#E0E0E0',
  }) async {
    try {
      final id = await dbInstance.insertCategory(
        db.CategoriesCompanion(
          name: Value(name),
          emoji: Value(emoji),
          isIncome: Value(isIncome),
          color: Value(color),
        ),
      );
      final cat = await dbInstance.getCategoryById(id);
      if (cat == null) {
        return Left(RepositoryFailure('Category not found after insert'));
      }
      return Right(cat.toDomain());
    } catch (e) {
      return Left(RepositoryFailure(e.toString()));
    }
  }

  Future<Either<Failure, bool>> deleteCategoryIfUnused(
    int categoryId,
    List<dynamic> allTransactions,
  ) async {
    try {
      // Проверяем, есть ли транзакции с этой категорией
      final transactions = await dbInstance.getAllTransactions();
      final hasTransactions = transactions.any(
        (t) => t.categoryId == categoryId,
      );
      if (hasTransactions) {
        return Right(false); // Категория используется, не удаляем
      }
      await dbInstance.deleteCategory(categoryId);
      return Right(true);
    } catch (e) {
      return Left(RepositoryFailure(e.toString()));
    }
  }

  Future<void> saveSearchQuery(String query) async {
    await dbInstance.saveSearchQuery(query);
  }

  Future<String?> getLastSearchQuery() async {
    return dbInstance.getLastSearchQuery();
  }

  Future<void> deleteSearchQuery() async {
    await dbInstance.deleteSearchQuery();
  }
}
