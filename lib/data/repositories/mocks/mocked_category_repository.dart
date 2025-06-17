import 'package:dartz/dartz.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'package:cashnetic/domain/failures/failure.dart';
import 'package:cashnetic/domain/failures/repository_failure.dart';
import 'package:cashnetic/domain/repositories/category_repository.dart';

class MockedCategoryRepository implements CategoryRepository {
  final List<Category> _mockCategories = [
    Category(id: 1, name: 'Зарплата', isIncome: true, emoji: ''),
    Category(id: 2, name: 'Подарок', isIncome: true, emoji: ''),
    Category(id: 3, name: 'Еда', isIncome: false, emoji: ''),
    Category(id: 4, name: 'Развлечения', isIncome: false, emoji: ''),
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
}
