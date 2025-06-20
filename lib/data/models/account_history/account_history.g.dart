// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AccountHistoryDTO _$AccountHistoryDTOFromJson(
  Map<String, dynamic> json,
) => _AccountHistoryDTO(
  id: (json['id'] as num).toInt(),
  accountId: (json['accountId'] as num).toInt(),
  changeType: json['changeType'] as String,
  previousState: json['previousState'] == null
      ? null
      : AccountStateDTO.fromJson(json['previousState'] as Map<String, dynamic>),
  newState: AccountStateDTO.fromJson(json['newState'] as Map<String, dynamic>),
  changeTimestamp: json['changeTimestamp'] as String,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$AccountHistoryDTOToJson(_AccountHistoryDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'accountId': instance.accountId,
      'changeType': instance.changeType,
      'previousState': instance.previousState,
      'newState': instance.newState,
      'changeTimestamp': instance.changeTimestamp,
      'createdAt': instance.createdAt,
    };
