import 'package:cashnetic/data/models/accout_state/account_state.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_history.freezed.dart';
part 'account_history.g.dart';

@freezed
abstract class AccountHistoryDTO with _$AccountHistoryDTO {
  const factory AccountHistoryDTO({
    required int id,
    required int accountId,
    required String changeType,
    required AccountStateDTO? previousState,
    required AccountStateDTO newState,
    required String changeTimestamp,
    required String createdAt,
  }) = _AccountHistoryDTO;

  factory AccountHistoryDTO.fromJson(Map<String, dynamic> json) =>
      _$AccountHistoryDTOFromJson(json);
}
