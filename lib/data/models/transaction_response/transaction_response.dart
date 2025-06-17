import 'package:cashnetic/data/models/account_brief/account_brief.dart';
import 'package:cashnetic/data/models/category/category.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_response.freezed.dart';
part 'transaction_response.g.dart';

@freezed
abstract class TransactionResponseDTO with _$TransactionResponseDTO {
  const factory TransactionResponseDTO({
    required int id,
    required AccountBriefDTO account,
    required CategoryDTO category,
    required String amount,
    required String transactionDate,
    required String? comment,
    required String createdAt,
    required String updatedAt,
  }) = _TransactionResponseDTO;

  factory TransactionResponseDTO.fromJson(Map<String, dynamic> json) =>
      _$TransactionResponseDTOFromJson(json);
}
