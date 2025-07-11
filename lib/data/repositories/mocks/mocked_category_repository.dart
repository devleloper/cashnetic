import 'package:dartz/dartz.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'package:cashnetic/domain/failures/failure.dart';
import 'package:cashnetic/domain/failures/repository_failure.dart';
import 'package:cashnetic/domain/entities/transaction.dart';

class MockedCategoryRepository {
  final List<Category> _mockCategories = [
    Category(
      id: 1,
      name: 'Products',
      emoji: '🛒',
      isIncome: false,
      color: '#4CAF50',
    ),
    Category(
      id: 2,
      name: 'Repair',
      emoji: '🏠',
      isIncome: false,
      color: '#FF9800',
    ),
    Category(
      id: 3,
      name: 'Clothes',
      emoji: '👗',
      isIncome: false,
      color: '#9C27B0',
    ),
    Category(
      id: 4,
      name: 'Electronics',
      emoji: '📱',
      isIncome: false,
      color: '#2196F3',
    ),
    Category(
      id: 5,
      name: 'Entertainment',
      emoji: '🎉',
      isIncome: false,
      color: '#E91E63',
    ),
    Category(
      id: 6,
      name: 'Education',
      emoji: '🎓',
      isIncome: false,
      color: '#3F51B5',
    ),
    Category(
      id: 7,
      name: 'Animals',
      emoji: '🐶',
      isIncome: false,
      color: '#795548',
    ),
    Category(
      id: 8,
      name: 'Health',
      emoji: '💊',
      isIncome: false,
      color: '#F44336',
    ),
    Category(
      id: 9,
      name: 'Presents',
      emoji: '🎁',
      isIncome: false,
      color: '#FF5722',
    ),
    Category(
      id: 10,
      name: 'Sports',
      emoji: '🏋️',
      isIncome: false,
      color: '#00BCD4',
    ),
    Category(
      id: 11,
      name: 'Transport',
      emoji: '🚌',
      isIncome: false,
      color: '#607D8B',
    ),
    Category(
      id: 12,
      name: 'Salary',
      emoji: '💼',
      isIncome: true,
      color: '#8BC34A',
    ),
    Category(
      id: 13,
      name: 'Side job',
      emoji: '🪙',
      isIncome: true,
      color: '#CDDC39',
    ),
  ];

  Future<Either<Failure, List<Category>>> getAllCategories() async {
    try {
      return right(_mockCategories);
    } catch (e) {
      return left(RepositoryFailure('Error getting categories'));
    }
  }

  Future<Either<Failure, List<Category>>> getCategoriesByIsIncome(
    bool isIncome,
  ) async {
    final filtered = _mockCategories
        .where((c) => c.isIncome == isIncome)
        .toList();
    return right(filtered);
  }

  Future<Either<Failure, Category>> addCategory({
    required String name,
    String emoji = '💰',
    required bool isIncome,
    String color = '#E0E0E0',
  }) async {
    try {
      final newCat = Category(
        id: _mockCategories.isNotEmpty
            ? _mockCategories.map((c) => c.id).reduce((a, b) => a > b ? a : b) +
                  1
            : 1,
        name: name,
        emoji: emoji,
        isIncome: isIncome,
        color: color,
      );
      _mockCategories.add(newCat);
      return right(newCat);
    } catch (e) {
      return left(RepositoryFailure('Error adding category: $e'));
    }
  }

  Future<Either<Failure, bool>> deleteCategory(int categoryId) async {
    try {
      final initialLen = _mockCategories.length;
      _mockCategories.removeWhere((c) => c.id == categoryId);
      final deleted = _mockCategories.length < initialLen;
      return right(deleted);
    } catch (e) {
      return left(RepositoryFailure('Error deleting category: $e'));
    }
  }

  /// Deletes a category if there are no transactions with this categoryId
  Future<Either<Failure, bool>> deleteCategoryIfUnused(
    int categoryId,
    List<dynamic> allTransactions,
  ) async {
    try {
      final used = allTransactions.any((t) => t.categoryId == categoryId);
      if (used) return right(false);
      return await deleteCategory(categoryId);
    } catch (e) {
      return left(
        RepositoryFailure('Error checking and deleting category: $e'),
      );
    }
  }
}
