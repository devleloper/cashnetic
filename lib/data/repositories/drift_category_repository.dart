import 'package:cashnetic/data/database.dart' as db;
import 'package:cashnetic/domain/entities/category.dart' as domain;
import 'package:cashnetic/domain/failures/failure.dart';
import 'package:cashnetic/domain/failures/repository_failure.dart';
import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:cashnetic/data/mappers/category_mapper.dart';
import 'package:flutter/foundation.dart';
import 'package:cashnetic/data/api_client.dart';
import 'package:cashnetic/data/models/category/category.dart';
import 'dart:convert';
import 'package:cashnetic/domain/entities/forms/category_form.dart';
import 'package:cashnetic/utils/diff_utils.dart';

class DriftCategoryRepository {
  final db.AppDatabase dbInstance;
  final ApiClient apiClient;

  DriftCategoryRepository(this.dbInstance, this.apiClient);

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
      // Get local categories
      final local = await dbInstance.getAllCategories();
      // API отключен — всегда возвращаем только локальные данные
      // RESTORE: чтобы снова включить API, раскомментируйте код ниже
      /*
      try {
        // Try to load from server
        final response = await apiClient.getCategories();
        final remoteCategories = (response.data as List)
            .map((json) => CategoryDTO.fromJson(json))
            .map(
              (dto) => db.Category(
                id: dto.id,
                name: dto.name,
                emoji: dto.emoji,
                isIncome: dto.isIncome,
                color: dto.color ?? '#E0E0E0',
              ),
            )
            .toList();
        // Replace all local categories with server ones
        await dbInstance.replaceAllCategories(remoteCategories);
        // Remove default categories if they remain (edge-case)
        final defaultNames = [
          'Продукты',
          'Ремонт',
          'Одежда',
          'Электроника',
          'Развлечения',
          'Образование',
          'Животные',
          'Здоровье',
          'Подарки',
          'Спорт',
          'Транспорт',
          'Зарплата',
          'Подработка',
        ];
        final allAfterReplace = await dbInstance.getAllCategories();
        for (final cat in allAfterReplace) {
          if (defaultNames.contains(cat.name)) {
            final isInRemote = remoteCategories.any(
              (r) => r.name == cat.name && r.isIncome == cat.isIncome,
            );
            if (!isInRemote) {
              await dbInstance.deleteCategory(cat.id);
            }
          }
        }
        debugPrint('[DriftCategoryRepository] EXIT getAllCategories (remote)');
        return Right(remoteCategories.map((c) => c.toDomain()).toList());
      */
      // Если сервер недоступен и локальных категорий нет — добавляем дефолтные
        if (local.isEmpty) {
          await _initDefaultCategories();
          final withDefaults = await dbInstance.getAllCategories();
        debugPrint('[DriftCategoryRepository] EXIT getAllCategories (defaults)');
          return Right(withDefaults.map((e) => e.toDomain()).toList());
        }
        debugPrint('[DriftCategoryRepository] EXIT getAllCategories (local)');
        return Right(local.map((e) => e.toDomain()).toList());
    } catch (e) {
      debugPrint(
        '[DriftCategoryRepository] ERROR in getAllCategories:  [31m${e.toString()} [0m',
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

  Future<Either<Failure, domain.Category>> createCategory(
    CategoryForm form,
  ) async {
    try {
      final id = await dbInstance.insertCategory(
        db.CategoriesCompanion(
          name: Value(form.name ?? ''),
          emoji: Value(form.emoji ?? ''),
          isIncome: Value(form.isIncome ?? false),
          color: Value(form.color ?? '#E0E0E0'),
        ),
      );
      // Save event to pending_events
      final dto = form.toCreateDTO();
      final payload = dto != null ? dto.toJson() : <String, dynamic>{};
      await dbInstance.insertPendingEvent(
        db.PendingEventsCompanion(
          entity: Value('category'),
          type: Value('create'),
          payload: Value(jsonEncode(payload)),
          createdAt: Value(DateTime.now()),
          status: Value('pending'),
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

  Future<Either<Failure, domain.Category>> updateCategory(
    int id,
    CategoryForm form,
  ) async {
    try {
      final existing = await dbInstance.getCategoryById(id);
      if (existing == null) {
        return Left(RepositoryFailure('Category not found'));
      }
      final updated = existing.copyWithCompanion(
        db.CategoriesCompanion(
          name: form.name != null ? Value(form.name!) : const Value.absent(),
          emoji: form.emoji != null ? Value(form.emoji!) : const Value.absent(),
          isIncome: form.isIncome != null
              ? Value(form.isIncome!)
              : const Value.absent(),
          color: form.color != null ? Value(form.color!) : const Value.absent(),
        ),
      );
      await dbInstance.updateCategory(updated);
      // --- DIFF LOGIC ---
      final oldJson = CategoryDTO(
        id: existing.id,
        name: existing.name,
        emoji: existing.emoji,
        isIncome: existing.isIncome,
        color: existing.color,
      ).toJson();
      final newJson = CategoryDTO(
        id: updated.id,
        name: updated.name,
        emoji: updated.emoji,
        isIncome: updated.isIncome,
        color: updated.color,
      ).toJson();
      final diff = generateDiff(oldJson, newJson);
      if (diff.isNotEmpty) {
        diff['id'] = id; // always include id for update
        await dbInstance.insertPendingEvent(
          db.PendingEventsCompanion(
            entity: Value('category'),
            type: Value('update'),
            payload: Value(jsonEncode(diff)),
            createdAt: Value(DateTime.now()),
            status: Value('pending'),
          ),
        );
        debugPrint(
          '[DriftCategoryRepository] Saved diff to pending_events: ' +
              diff.toString(),
        );
      } else {
        debugPrint(
          '[DriftCategoryRepository] No diff detected, nothing to sync',
        );
      }
      final cat = await dbInstance.getCategoryById(id);
      if (cat == null) {
        return Left(RepositoryFailure('Category not found after update'));
      }
      return Right(cat.toDomain());
    } catch (e) {
      return Left(RepositoryFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deleteCategory(int id) async {
    try {
      await dbInstance.deleteCategory(id);
      // Save event to pending_events
      await dbInstance.insertPendingEvent(
        db.PendingEventsCompanion(
          entity: Value('category'),
          type: Value('delete'),
          payload: Value(jsonEncode({'id': id})),
          createdAt: Value(DateTime.now()),
          status: Value('pending'),
        ),
      );
      return Right(null);
    } catch (e) {
      return Left(RepositoryFailure(e.toString()));
    }
  }

  Future<Either<Failure, bool>> deleteCategoryIfUnused(
    int categoryId,
    List<dynamic> allTransactions,
  ) async {
    try {
      // Check if there are transactions with this category
      final transactions = await dbInstance.getAllTransactions();
      final hasTransactions = transactions.any(
        (t) => t.categoryId == categoryId,
      );
      if (hasTransactions) {
        return Right(false); // Category is used, do not delete
      }
      await dbInstance.deleteCategory(categoryId);
      return Right(true);
    } catch (e) {
      return Left(RepositoryFailure(e.toString()));
    }
  }
}
