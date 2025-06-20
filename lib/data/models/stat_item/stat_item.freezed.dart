// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stat_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StatItemDTO {

 int get categoryId; String get categoryName; String get emoji; String get amount;
/// Create a copy of StatItemDTO
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatItemDTOCopyWith<StatItemDTO> get copyWith => _$StatItemDTOCopyWithImpl<StatItemDTO>(this as StatItemDTO, _$identity);

  /// Serializes this StatItemDTO to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatItemDTO&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,categoryId,categoryName,emoji,amount);

@override
String toString() {
  return 'StatItemDTO(categoryId: $categoryId, categoryName: $categoryName, emoji: $emoji, amount: $amount)';
}


}

/// @nodoc
abstract mixin class $StatItemDTOCopyWith<$Res>  {
  factory $StatItemDTOCopyWith(StatItemDTO value, $Res Function(StatItemDTO) _then) = _$StatItemDTOCopyWithImpl;
@useResult
$Res call({
 int categoryId, String categoryName, String emoji, String amount
});




}
/// @nodoc
class _$StatItemDTOCopyWithImpl<$Res>
    implements $StatItemDTOCopyWith<$Res> {
  _$StatItemDTOCopyWithImpl(this._self, this._then);

  final StatItemDTO _self;
  final $Res Function(StatItemDTO) _then;

/// Create a copy of StatItemDTO
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categoryId = null,Object? categoryName = null,Object? emoji = null,Object? amount = null,}) {
  return _then(_self.copyWith(
categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _StatItemDTO implements StatItemDTO {
  const _StatItemDTO({required this.categoryId, required this.categoryName, required this.emoji, required this.amount});
  factory _StatItemDTO.fromJson(Map<String, dynamic> json) => _$StatItemDTOFromJson(json);

@override final  int categoryId;
@override final  String categoryName;
@override final  String emoji;
@override final  String amount;

/// Create a copy of StatItemDTO
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatItemDTOCopyWith<_StatItemDTO> get copyWith => __$StatItemDTOCopyWithImpl<_StatItemDTO>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StatItemDTOToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatItemDTO&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,categoryId,categoryName,emoji,amount);

@override
String toString() {
  return 'StatItemDTO(categoryId: $categoryId, categoryName: $categoryName, emoji: $emoji, amount: $amount)';
}


}

/// @nodoc
abstract mixin class _$StatItemDTOCopyWith<$Res> implements $StatItemDTOCopyWith<$Res> {
  factory _$StatItemDTOCopyWith(_StatItemDTO value, $Res Function(_StatItemDTO) _then) = __$StatItemDTOCopyWithImpl;
@override @useResult
$Res call({
 int categoryId, String categoryName, String emoji, String amount
});




}
/// @nodoc
class __$StatItemDTOCopyWithImpl<$Res>
    implements _$StatItemDTOCopyWith<$Res> {
  __$StatItemDTOCopyWithImpl(this._self, this._then);

  final _StatItemDTO _self;
  final $Res Function(_StatItemDTO) _then;

/// Create a copy of StatItemDTO
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categoryId = null,Object? categoryName = null,Object? emoji = null,Object? amount = null,}) {
  return _then(_StatItemDTO(
categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
