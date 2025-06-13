// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) =>
    _TransactionModel(
      id: (json['id'] as num).toInt(),
      categoryId: (json['categoryId'] as num).toInt(),
      account: json['account'] as String,
      categoryIcon: json['categoryIcon'] as String,
      categoryTitle: json['categoryTitle'] as String,
      type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
      comment: json['comment'] as String?,
      amount: (json['amount'] as num).toDouble(),
      transactionDate: DateTime.parse(json['transactionDate'] as String),
    );

Map<String, dynamic> _$TransactionModelToJson(_TransactionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'categoryId': instance.categoryId,
      'account': instance.account,
      'categoryIcon': instance.categoryIcon,
      'categoryTitle': instance.categoryTitle,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'comment': instance.comment,
      'amount': instance.amount,
      'transactionDate': instance.transactionDate.toIso8601String(),
    };

const _$TransactionTypeEnumMap = {
  TransactionType.income: 'income',
  TransactionType.expense: 'expense',
};
