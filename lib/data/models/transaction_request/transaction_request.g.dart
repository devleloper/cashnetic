// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TransactionRequestDTO _$TransactionRequestDTOFromJson(
  Map<String, dynamic> json,
) => _TransactionRequestDTO(
  accountId: (json['accountId'] as num?)?.toInt(),
  categoryId: (json['categoryId'] as num?)?.toInt(),
  amount: json['amount'] as String?,
  transactionDate: json['transactionDate'] as String?,
  comment: json['comment'] as String?,
);

Map<String, dynamic> _$TransactionRequestDTOToJson(
  _TransactionRequestDTO instance,
) => <String, dynamic>{
  'accountId': instance.accountId,
  'categoryId': instance.categoryId,
  'amount': instance.amount,
  'transactionDate': instance.transactionDate,
  'comment': instance.comment,
};
