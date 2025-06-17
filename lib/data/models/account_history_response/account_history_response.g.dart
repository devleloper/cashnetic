// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_history_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AccountHistoryResponseDTO _$AccountHistoryResponseDTOFromJson(
  Map<String, dynamic> json,
) => _AccountHistoryResponseDTO(
  accountId: (json['accountId'] as num).toInt(),
  accountName: json['accountName'] as String,
  currency: json['currency'] as String,
  currentBalance: json['currentBalance'] as String,
  history:
      (json['history'] as List<dynamic>)
          .map((e) => AccountHistoryDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$AccountHistoryResponseDTOToJson(
  _AccountHistoryResponseDTO instance,
) => <String, dynamic>{
  'accountId': instance.accountId,
  'accountName': instance.accountName,
  'currency': instance.currency,
  'currentBalance': instance.currentBalance,
  'history': instance.history,
};
