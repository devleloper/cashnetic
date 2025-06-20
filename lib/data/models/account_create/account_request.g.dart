// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AccountRequestDTO _$AccountRequestDTOFromJson(Map<String, dynamic> json) =>
    _AccountRequestDTO(
      name: json['name'] as String?,
      balance: json['balance'] as String?,
      currency: json['currency'] as String?,
    );

Map<String, dynamic> _$AccountRequestDTOToJson(_AccountRequestDTO instance) =>
    <String, dynamic>{
      'name': instance.name,
      'balance': instance.balance,
      'currency': instance.currency,
    };
