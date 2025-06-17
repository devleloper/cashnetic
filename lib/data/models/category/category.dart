import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';
part 'category.g.dart';

@freezed
abstract class CategoryDTO with _$CategoryDTO {
  const factory CategoryDTO({
    required int id,
    required String name,
    required String emoji,
    required bool isIncome,
  }) = _CategoryDTO;

  factory CategoryDTO.fromJson(Map<String, dynamic> json) =>
      _$CategoryDTOFromJson(json);
}
