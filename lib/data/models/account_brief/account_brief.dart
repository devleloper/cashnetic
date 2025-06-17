import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_brief.freezed.dart';
part 'account_brief.g.dart';

@freezed
abstract class AccountBriefDTO with _$AccountBriefDTO {
  const factory AccountBriefDTO({
    required int id,
    required String name,
    required String balance,
    required String currency,
  }) = _AccountBriefDTO;

  factory AccountBriefDTO.fromJson(Map<String, dynamic> json) =>
      _$AccountBriefDTOFromJson(json);
}
