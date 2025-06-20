import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_request.freezed.dart';
part 'account_request.g.dart';

@freezed
abstract class AccountRequestDTO with _$AccountRequestDTO {
  const factory AccountRequestDTO({
    required String? name,
    required String? balance,
    required String? currency,
  }) = _AccountRequestDTO;

  factory AccountRequestDTO.fromJson(Map<String, dynamic> json) =>
      _$AccountRequestDTOFromJson(json);
}
