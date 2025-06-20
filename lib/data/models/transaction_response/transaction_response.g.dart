// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TransactionResponseDTO _$TransactionResponseDTOFromJson(
  Map<String, dynamic> json,
) => _TransactionResponseDTO(
  id: (json['id'] as num).toInt(),
  account: AccountBriefDTO.fromJson(json['account'] as Map<String, dynamic>),
  category: CategoryDTO.fromJson(json['category'] as Map<String, dynamic>),
  amount: json['amount'] as String,
  transactionDate: json['transactionDate'] as String,
  comment: json['comment'] as String?,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
);

Map<String, dynamic> _$TransactionResponseDTOToJson(
  _TransactionResponseDTO instance,
) => <String, dynamic>{
  'id': instance.id,
  'account': instance.account,
  'category': instance.category,
  'amount': instance.amount,
  'transactionDate': instance.transactionDate,
  'comment': instance.comment,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};
