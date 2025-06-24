import 'package:cashnetic/data/database.dart' as db;
import 'package:cashnetic/domain/entities/category.dart';
import 'package:cashnetic/domain/failures/failure.dart';
import 'package:cashnetic/domain/failures/repository_failure.dart';
import 'package:cashnetic/domain/repositories/category_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';

class DriftCategoryRepository implements CategoryRepository {
  final db.AppDatabase dbInstance;

  DriftCategoryRepository(this.dbInstance);

  @override
  Future<Either<Failure, List<Category>>> getAllCategories() async {
    try {
      final data = await dbInstance.getAllCategories();
      return Right(
        data
            .map(
              (e) => Category(
                id: e.id,
                name: e.name,
                emoji: e.emoji,
                isIncome: e.isIncome,
                color: e.color,
              ),
            )
            .toList(),
      );
    } catch (e) {
      return Left(RepositoryFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getCategoriesByIsIncome(
    bool isIncome,
  ) async {
    try {
      final data = await dbInstance.getAllCategories();
      final filtered = data
          .where((e) => e.isIncome == isIncome)
          .map(
            (e) => Category(
              id: e.id,
              name: e.name,
              emoji: e.emoji,
              isIncome: e.isIncome,
              color: e.color,
            ),
          )
          .toList();
      return Right(filtered);
    } catch (e) {
      return Left(RepositoryFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Category>> addCategory({
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
      if (cat == null)
        return Left(RepositoryFailure('Category not found after insert'));
      return Right(
        Category(
          id: cat.id,
          name: cat.name,
          emoji: cat.emoji,
          isIncome: cat.isIncome,
          color: cat.color,
        ),
      );
    } catch (e) {
      return Left(RepositoryFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteCategoryIfUnused(
    int categoryId,
    List<dynamic> allTransactions,
  ) async {
    // TODO: реализовать проверку на отсутствие транзакций с этой категорией
    try {
      await dbInstance.deleteCategory(categoryId);
      return Right(true);
    } catch (e) {
      return Left(RepositoryFailure(e.toString()));
    }
  }
}
