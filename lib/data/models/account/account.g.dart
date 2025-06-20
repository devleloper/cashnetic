// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AccountDTO _$AccountDTOFromJson(Map<String, dynamic> json) => _AccountDTO(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  name: json['name'] as String,
  balance: json['balance'] as String,
  currency: json['currency'] as String,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
);

Map<String, dynamic> _$AccountDTOToJson(_AccountDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'balance': instance.balance,
      'currency': instance.currency,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
