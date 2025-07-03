// categories_repository.dart
import 'package:dartz/dartz.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'package:cashnetic/domain/entities/transaction.dart';
import 'package:cashnetic/domain/failures/failure.dart';
import 'package:cashnetic/domain/repositories/category_repository.dart';
import 'package:cashnetic/domain/repositories/transaction_repository.dart';
import 'package:cashnetic/domain/failures/repository_failure.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';

abstract interface class CategoriesRepository {
  Future<Either<Failure, List<Category>>> getAllCategories();
  Future<Either<Failure, List<Category>>> searchCategories(String query);
  Future<Either<Failure, void>> addCategory(Category category);
  Future<Either<Failure, void>> deleteCategory(int categoryId);
  Future<Either<Failure, Map<int, List<Transaction>>>>
  getTransactionsByCategory();
}

class CategoriesRepositoryImpl implements CategoriesRepository {
  final CategoryRepository categoryRepository;
  final TransactionRepository transactionRepository;

  CategoriesRepositoryImpl({
    required this.categoryRepository,
    required this.transactionRepository,
  });

  @override
  Future<Either<Failure, List<Category>>> getAllCategories() async {
    return await categoryRepository.getAllCategories();
  }

  @override
  Future<Either<Failure, List<Category>>> searchCategories(String query) async {
    final result = await categoryRepository.getAllCategories();
    return result.fold((failure) => left(failure), (categories) {
      if (query.isEmpty) return right(categories);
      final choices = categories.map((c) => c.name).toList();
      final results = extractTop(
        query: query,
        choices: choices,
        limit: 20,
        cutoff: 60,
      );
      final names = results.map((r) => r.choice).toSet();
      final filtered = categories.where((c) => names.contains(c.name)).toList();
      return right(filtered);
    });
  }

  @override
  Future<Either<Failure, void>> addCategory(Category category) async {
    // Реализовать добавление категории через categoryRepository, если поддерживается
    // Здесь просто возвращаем ошибку-заглушку
    return left(RepositoryFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, void>> deleteCategory(int categoryId) async {
    // Реализовать удаление категории через categoryRepository, если поддерживается
    // Здесь просто возвращаем ошибку-заглушку
    return left(RepositoryFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, Map<int, List<Transaction>>>>
  getTransactionsByCategory() async {
    final txResult = await transactionRepository.getTransactionsByPeriod(
      0,
      DateTime(2000),
      DateTime.now(),
    );
    final allTx = txResult.fold((_) => <Transaction>[], (txs) => txs);
    final catResult = await categoryRepository.getAllCategories();
    return catResult.fold((failure) => left(failure), (categories) {
      final Map<int, List<Transaction>> txByCategory = {};
      for (final cat in categories) {
        txByCategory[cat.id] = allTx
            .where((t) => t.categoryId == cat.id)
            .toList();
      }
      return right(txByCategory);
    });
  }
}
