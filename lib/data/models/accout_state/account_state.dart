import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_state.freezed.dart';
part 'account_state.g.dart';

@freezed
abstract class AccountStateDTO with _$AccountStateDTO {
  const factory AccountStateDTO({
    required int id,
    required String name,
    required String balance,
    required String currency,
  }) = _AccountStateDTO;

  factory AccountStateDTO.fromJson(Map<String, dynamic> json) =>
      _$AccountStateDTOFromJson(json);
}
