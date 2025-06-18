import 'package:dartz/dartz.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'package:cashnetic/domain/failures/failure.dart';
import 'package:cashnetic/domain/failures/repository_failure.dart';
import 'package:cashnetic/domain/repositories/category_repository.dart';

class MockedCategoryRepository implements CategoryRepository {
  final List<Category> _mockCategories = [
    Category(
      id: 1,
      name: 'Зарплата',
      isIncome: true,
      emoji: '',
      color: '#A5D6A7',
    ),
    Category(
      id: 2,
      name: 'Подарок',
      isIncome: true,
      emoji: '',
      color: '#90CAF9',
    ),
    Category(id: 3, name: 'Еда', isIncome: false, emoji: '', color: '#FFF59D'),
    Category(
      id: 4,
      name: 'Развлечения',
      isIncome: false,
      emoji: '',
      color: '#F48FB1',
    ),
  ];

  @override
  Future<Either<Failure, List<Category>>> getAllCategories() async {
    try {
      return right(_mockCategories);
    } catch (e) {
      return left(RepositoryFailure('Ошибка при получении категорий'));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getCategoriesByIsIncome(
    bool isIncome,
  ) async {
    final filtered = _mockCategories
        .where((c) => c.isIncome == isIncome)
        .toList();
    return right(filtered);
  }

  @override
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
      return left(RepositoryFailure('Ошибка при добавлении категории: $e'));
    }
  }
}
