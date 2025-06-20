import 'package:dartz/dartz.dart';
import 'package:cashnetic/domain/repositories/transaction_repository.dart';
import 'package:cashnetic/domain/entities/transaction.dart';
import 'package:cashnetic/domain/failures/failure.dart';
import 'package:cashnetic/domain/failures/repository_failure.dart';

class SharedPrefsHistoryRepository {
  final TransactionRepository transactionRepository;

  SharedPrefsHistoryRepository({required this.transactionRepository});

  Future<Either<Failure, List<Transaction>>> loadAllTransactions() async {
    try {
      // Получаем все транзакции за последний год
      final now = DateTime.now();
      final oneYearAgo = DateTime(now.year - 1, now.month, now.day);

      final result = await transactionRepository.getTransactionsByPeriod(
        1, // TODO: получить реальный accountId или все аккаунты
        oneYearAgo,
        now,
      );

      return result.fold(
        (failure) => Left(failure),
        (transactions) => Right(transactions),
      );
    } catch (e) {
      return Left(
        RepositoryFailure('Ошибка при загрузке истории транзакций: $e'),
      );
    }
  }

  Future<Either<Failure, List<Transaction>>> loadTransactionsByAccount(
    int accountId,
  ) async {
    try {
      final now = DateTime.now();
      final oneYearAgo = DateTime(now.year - 1, now.month, now.day);

      final result = await transactionRepository.getTransactionsByPeriod(
        accountId,
        oneYearAgo,
        now,
      );

      return result.fold(
        (failure) => Left(failure),
        (transactions) => Right(transactions),
      );
    } catch (e) {
      return Left(
        RepositoryFailure('Ошибка при загрузке истории транзакций: $e'),
      );
    }
  }

  Future<Either<Failure, List<Transaction>>> loadTransactionsByPeriod({
    required DateTime from,
    required DateTime to,
    int? accountId,
  }) async {
    try {
      final targetAccountId =
          accountId ?? 1; // TODO: получить реальный accountId

      final result = await transactionRepository.getTransactionsByPeriod(
        targetAccountId,
        from,
        to,
      );

      return result.fold(
        (failure) => Left(failure),
        (transactions) => Right(transactions),
      );
    } catch (e) {
      return Left(
        RepositoryFailure('Ошибка при загрузке истории транзакций: $e'),
      );
    }
  }
}
