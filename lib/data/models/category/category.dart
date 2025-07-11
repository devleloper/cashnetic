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
    String? color,
  }) = _CategoryDTO;

  factory CategoryDTO.fromJson(Map<String, dynamic> json) => _CategoryDTO(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String,
    emoji: json['emoji'] as String,
    isIncome: json['isIncome'] as bool,
    color: json['color'] as String? ?? '#E0E0E0',
  );
}
