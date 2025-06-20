import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_request.freezed.dart';
part 'transaction_request.g.dart';

@freezed
abstract class TransactionRequestDTO with _$TransactionRequestDTO {
  const factory TransactionRequestDTO({
    required int? accountId,
    required int? categoryId,
    required String? amount,
    required String? transactionDate,
    required String? comment,
  }) = _TransactionRequestDTO;

  factory TransactionRequestDTO.fromJson(Map<String, dynamic> json) =>
      _$TransactionRequestDTOFromJson(json);
}
