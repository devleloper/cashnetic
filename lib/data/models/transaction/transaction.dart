import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

@freezed
abstract class TransactionDTO with _$TransactionDTO {
  const factory TransactionDTO({
    required int id,
    required int accountId,
    required int categoryId,
    required String amount,
    required String transactionDate,
    required String? comment,
    required String createdAt,
    required String updatedAt,
  }) = _TransactionDTO;

  factory TransactionDTO.fromJson(Map<String, dynamic> json) =>
      _$TransactionDTOFromJson(json);
}
