// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_brief.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AccountBriefDTO _$AccountBriefDTOFromJson(Map<String, dynamic> json) =>
    _AccountBriefDTO(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      balance: json['balance'] as String,
      currency: json['currency'] as String,
    );

Map<String, dynamic> _$AccountBriefDTOToJson(_AccountBriefDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'balance': instance.balance,
      'currency': instance.currency,
    };
