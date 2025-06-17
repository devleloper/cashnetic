import 'package:freezed_annotation/freezed_annotation.dart';

part 'stat_item.freezed.dart';
part 'stat_item.g.dart';

@freezed
abstract class StatItemDTO with _$StatItemDTO {
  const factory StatItemDTO({
    required int categoryId,
    required String categoryName,
    required String emoji,
    required String amount,
  }) = _StatItemDTO;

  factory StatItemDTO.fromJson(Map<String, dynamic> json) =>
      _$StatItemDTOFromJson(json);
}
