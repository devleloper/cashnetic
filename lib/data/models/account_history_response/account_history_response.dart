import 'package:freezed_annotation/freezed_annotation.dart';

import '../account_history/account_history.dart';

part 'account_history_response.freezed.dart';
part 'account_history_response.g.dart';

@freezed
abstract class AccountHistoryResponseDTO with _$AccountHistoryResponseDTO {
  const factory AccountHistoryResponseDTO({
    required int accountId,
    required String accountName,
    required String currency,
    required String currentBalance,
    required List<AccountHistoryDTO> history,
  }) = _AccountHistoryResponseDTO;

  factory AccountHistoryResponseDTO.fromJson(Map<String, dynamic> json) =>
      _$AccountHistoryResponseDTOFromJson(json);
}
