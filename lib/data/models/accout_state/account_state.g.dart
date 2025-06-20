// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AccountStateDTO _$AccountStateDTOFromJson(Map<String, dynamic> json) =>
    _AccountStateDTO(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      balance: json['balance'] as String,
      currency: json['currency'] as String,
    );

Map<String, dynamic> _$AccountStateDTOToJson(_AccountStateDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'balance': instance.balance,
      'currency': instance.currency,
    };
