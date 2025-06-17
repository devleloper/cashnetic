// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CategoryDTO _$CategoryDTOFromJson(Map<String, dynamic> json) => _CategoryDTO(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  emoji: json['emoji'] as String,
  isIncome: json['isIncome'] as bool,
);

Map<String, dynamic> _$CategoryDTOToJson(_CategoryDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'emoji': instance.emoji,
      'isIncome': instance.isIncome,
    };
