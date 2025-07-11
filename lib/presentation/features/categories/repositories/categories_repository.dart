// categories_repository.dart
import 'package:dartz/dartz.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'package:cashnetic/domain/entities/transaction.dart';
import 'package:cashnetic/domain/failures/failure.dart';
import 'package:cashnetic/presentation/features/transactions/repositories/transactions_repository.dart';
import 'package:cashnetic/domain/failures/repository_failure.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:cashnetic/data/repositories/drift_category_repository.dart';

abstract interface class CategoriesRepository {
  Future<Either<Failure, List<Category>>> getAllCategories();
  Future<List<Category>> getCategories();
  Future<Either<Failure, List<Category>>> searchCategories(String query);
  Future<Either<Failure, void>> addCategory(Category category);
  Future<Either<Failure, void>> deleteCategory(int categoryId);
  Future<Either<Failure, Map<int, List<Transaction>>>>
  getTransactionsByCategory();
}

class CategoriesRepositoryImpl implements CategoriesRepository {
  final DriftCategoryRepository driftCategoryRepository;
  final TransactionsRepository transactionsRepository;

  CategoriesRepositoryImpl({
    required this.driftCategoryRepository,
    required this.transactionsRepository,
  });

  @override
  Future<Either<Failure, List<Category>>> getAllCategories() async {
    return await driftCategoryRepository.getAllCategories();
  }

  @override
  Future<List<Category>> getCategories() async {
    final result = await driftCategoryRepository.getAllCategories();
    return result.fold((_) => <Category>[], (cats) => cats);
  }

  @override
  Future<Either<Failure, List<Category>>> searchCategories(String query) async {
    try {
      final allResult = await driftCategoryRepository.getAllCategories();
      return allResult.fold((failure) => left(failure), (allCategories) {
        if (query.trim().isEmpty) return right(allCategories);
        final results = extractAll(
          query: query,
          choices: allCategories,
          cutoff: 60,
          getter: (cat) => cat.name,
        );
        final filtered = results.take(20).map((r) => r.choice).toList();
        return right(filtered);
      });
    } catch (e) {
      return left(RepositoryFailure('Search failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addCategory(Category category) async {
    return left(RepositoryFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, void>> deleteCategory(int categoryId) async {
    return left(RepositoryFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, Map<int, List<Transaction>>>>
  getTransactionsByCategory() async {
    try {
      final (txs, _) = await transactionsRepository.getTransactions();
      final Map<int, List<Transaction>> byCategory = {};
      for (final tx in txs) {
        if (tx.categoryId != null) {
          byCategory.putIfAbsent(tx.categoryId!, () => []).add(tx);
        }
      }
      return right(byCategory);
    } catch (e) {
      return left(
        RepositoryFailure('Failed to group transactions by category: $e'),
      );
    }
  }
}
