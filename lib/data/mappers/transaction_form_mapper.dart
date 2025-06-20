import 'package:dartz/dartz.dart';
import 'package:cashnetic/data/models/transaction_request/transaction_request.dart';
import 'package:cashnetic/domain/entities/forms/transaction_form.dart';
import 'package:cashnetic/domain/failures/failure.dart';

extension TransactionFormMapper on TransactionForm {
  Either<Failure, TransactionRequestDTO> toDTO() {
    return right(
      TransactionRequestDTO(
        accountId: accountId,
        categoryId: categoryId,
        amount: amount?.toString(),
        transactionDate: timestamp.toString(),
        comment: comment,
      ),
    );
  }
}
