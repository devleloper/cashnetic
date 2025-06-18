import 'package:cashnetic/domain/entities/transaction.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'package:cashnetic/models/models.dart';

class TransactionMapper {
  static TransactionModel domainToModel(
    Transaction transaction,
    Category category,
    String accountName,
  ) {
    return TransactionModel(
      id: transaction.id,
      categoryId: transaction.categoryId ?? 0,
      account: accountName,
      categoryIcon: category.emoji,
      categoryTitle: category.name,
      type: category.isIncome
          ? TransactionType.income
          : TransactionType.expense,
      comment: transaction.comment,
      amount: transaction.amount,
      transactionDate: transaction.timestamp,
    );
  }

  static TransactionModel domainToModelWithDefaultCategory(
    Transaction transaction,
    String accountName,
  ) {
    return TransactionModel(
      id: transaction.id,
      categoryId: transaction.categoryId ?? 0,
      account: accountName,
      categoryIcon: '💰', // Эмоджи по умолчанию
      categoryTitle: 'Категория', // Название по умолчанию
      type: TransactionType.expense, // По умолчанию расход
      comment: transaction.comment,
      amount: transaction.amount,
      transactionDate: transaction.timestamp,
    );
  }
}
