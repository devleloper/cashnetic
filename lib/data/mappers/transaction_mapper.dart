import 'package:dartz/dartz.dart';
import 'package:cashnetic/data/mappers/types/try_parse_datetime.dart';
import 'package:cashnetic/data/mappers/types/try_parse_double.dart';
import 'package:cashnetic/data/models/transaction/transaction.dart';
import 'package:cashnetic/domain/entities/transaction.dart' as domain;
import 'package:cashnetic/domain/entities/value_objects/time_interval.dart';
import 'package:cashnetic/domain/failures/failure.dart';

import '../models/transaction_response/transaction_response.dart';
import '../models/category/category.dart';
import '../models/account_brief/account_brief.dart';
import 'package:cashnetic/data/database.dart' as db;

extension TransactionMapper on TransactionDTO {
  Either<Failure, domain.Transaction> toDomain() {
    final amountOrFailure = tryParseDouble(amount, 'amount');
    final transactionDateOrFailure = tryParseDateTime(
      transactionDate,
      'transactionDate',
    );
    final createdAtOrFailure = tryParseDateTime(createdAt, 'createdAt');
    final updatedAtOrFailure = tryParseDateTime(updatedAt, 'updatedAt');

    return amountOrFailure.flatMap(
      (parsedAmount) => transactionDateOrFailure.flatMap(
        (parsedTransactionDate) => createdAtOrFailure.flatMap(
          (parsedCreatedAt) => updatedAtOrFailure.map(
            (parsedUpdatedAt) => domain.Transaction(
              id: this.id,
              accountId: accountId,
              categoryId: categoryId,
              amount: parsedAmount,
              timestamp: parsedTransactionDate,
              comment: comment,
              timeInterval: TimeInterval(
                createdAt: parsedCreatedAt,
                updatedAt: parsedUpdatedAt,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension TransactionResponseMapper on TransactionResponseDTO {
  Either<Failure, domain.Transaction> toDomain() {
    final amountOrFailure = tryParseDouble(amount, 'amount');
    final transactionDateOrFailure = tryParseDateTime(
      transactionDate,
      'transactionDate',
    );
    final accountId = account.id;
    final createdAtOrFailure = tryParseDateTime(createdAt, 'createdAt');
    final updatedAtOrFailure = tryParseDateTime(updatedAt, 'updatedAt');
    final categoryId = category.id;

    return amountOrFailure.flatMap(
      (parsedAmount) => transactionDateOrFailure.flatMap(
        (parsedTransactionDate) => createdAtOrFailure.flatMap(
          (parsedCreatedAt) => updatedAtOrFailure.map(
            (parsedUpdatedAt) => domain.Transaction(
              id: this.id,
              accountId: accountId,
              categoryId: categoryId,
              amount: parsedAmount,
              timestamp: parsedTransactionDate,
              comment: comment,
              timeInterval: TimeInterval(
                createdAt: parsedCreatedAt,
                updatedAt: parsedUpdatedAt,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TransactionDomainMapper {
  static TransactionResponseDTO domainToModel(
    domain.Transaction transaction,
    CategoryDTO category,
    String accountName, {
    String? currency,
  }) {
    return TransactionResponseDTO(
      id: transaction.id,
      account: AccountBriefDTO(
        id: transaction.accountId,
        name: accountName,
        balance: '0', // Default balance
        currency: currency ?? 'RUB',
      ),
      category: category,
      amount: transaction.amount.toString(),
      transactionDate: transaction.timestamp.toIso8601String(),
      comment: transaction.comment,
      createdAt: transaction.timeInterval.createdAt.toIso8601String(),
      updatedAt: transaction.timeInterval.updatedAt.toIso8601String(),
    );
  }
}

extension DbTransactionMapper on db.Transaction {
  domain.Transaction toDomain() {
    return domain.Transaction(
      id: this.id,
      accountId: this.accountId,
      categoryId: this.categoryId,
      amount: this.amount,
      timestamp: this.timestamp,
      comment: this.comment,
      timeInterval: TimeInterval(
        createdAt: this.createdAt,
        updatedAt: this.updatedAt,
      ),
    );
  }
}
