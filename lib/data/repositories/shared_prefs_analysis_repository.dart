import 'package:dartz/dartz.dart';
import 'package:cashnetic/domain/repositories/transaction_repository.dart';
import 'package:cashnetic/domain/entities/transaction.dart';
import 'package:cashnetic/domain/failures/failure.dart';
import 'package:cashnetic/domain/failures/repository_failure.dart';

class SharedPrefsAnalysisRepository {
  final TransactionRepository transactionRepository;

  SharedPrefsAnalysisRepository({required this.transactionRepository});

  Future<Either<Failure, List<Transaction>>> fetchTransactionsByPeriod({
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      // Получаем все транзакции за период
      final result = await transactionRepository.getTransactionsByPeriod(
        1, // TODO: получить реальный accountId
        from,
        to,
      );

      return result.fold(
        (failure) => Left(failure),
        (transactions) => Right(transactions),
      );
    } catch (e) {
      return Left(
        RepositoryFailure('Ошибка при получении транзакций для анализа: $e'),
      );
    }
  }

  Future<Either<Failure, List<Transaction>>>
  fetchTransactionsByAccountAndPeriod({
    required int accountId,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final result = await transactionRepository.getTransactionsByPeriod(
        accountId,
        from,
        to,
      );

      return result.fold(
        (failure) => Left(failure),
        (transactions) => Right(transactions),
      );
    } catch (e) {
      return Left(
        RepositoryFailure('Ошибка при получении транзакций для анализа: $e'),
      );
    }
  }
}
