// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CategoryDTO {

 int get id; String get name; String get emoji; bool get isIncome;
/// Create a copy of CategoryDTO
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryDTOCopyWith<CategoryDTO> get copyWith => _$CategoryDTOCopyWithImpl<CategoryDTO>(this as CategoryDTO, _$identity);

  /// Serializes this CategoryDTO to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryDTO&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.isIncome, isIncome) || other.isIncome == isIncome));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,emoji,isIncome);

@override
String toString() {
  return 'CategoryDTO(id: $id, name: $name, emoji: $emoji, isIncome: $isIncome)';
}


}

/// @nodoc
abstract mixin class $CategoryDTOCopyWith<$Res>  {
  factory $CategoryDTOCopyWith(CategoryDTO value, $Res Function(CategoryDTO) _then) = _$CategoryDTOCopyWithImpl;
@useResult
$Res call({
 int id, String name, String emoji, bool isIncome
});




}
/// @nodoc
class _$CategoryDTOCopyWithImpl<$Res>
    implements $CategoryDTOCopyWith<$Res> {
  _$CategoryDTOCopyWithImpl(this._self, this._then);

  final CategoryDTO _self;
  final $Res Function(CategoryDTO) _then;

/// Create a copy of CategoryDTO
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? emoji = null,Object? isIncome = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,isIncome: null == isIncome ? _self.isIncome : isIncome // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _CategoryDTO implements CategoryDTO {
  const _CategoryDTO({required this.id, required this.name, required this.emoji, required this.isIncome});
  factory _CategoryDTO.fromJson(Map<String, dynamic> json) => _$CategoryDTOFromJson(json);

@override final  int id;
@override final  String name;
@override final  String emoji;
@override final  bool isIncome;

/// Create a copy of CategoryDTO
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryDTOCopyWith<_CategoryDTO> get copyWith => __$CategoryDTOCopyWithImpl<_CategoryDTO>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CategoryDTOToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryDTO&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.isIncome, isIncome) || other.isIncome == isIncome));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,emoji,isIncome);

@override
String toString() {
  return 'CategoryDTO(id: $id, name: $name, emoji: $emoji, isIncome: $isIncome)';
}


}

/// @nodoc
abstract mixin class _$CategoryDTOCopyWith<$Res> implements $CategoryDTOCopyWith<$Res> {
  factory _$CategoryDTOCopyWith(_CategoryDTO value, $Res Function(_CategoryDTO) _then) = __$CategoryDTOCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String emoji, bool isIncome
});




}
/// @nodoc
class __$CategoryDTOCopyWithImpl<$Res>
    implements _$CategoryDTOCopyWith<$Res> {
  __$CategoryDTOCopyWithImpl(this._self, this._then);

  final _CategoryDTO _self;
  final $Res Function(_CategoryDTO) _then;

/// Create a copy of CategoryDTO
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? emoji = null,Object? isIncome = null,}) {
  return _then(_CategoryDTO(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,isIncome: null == isIncome ? _self.isIncome : isIncome // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
