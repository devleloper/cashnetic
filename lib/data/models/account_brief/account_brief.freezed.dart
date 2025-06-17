// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_brief.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AccountBriefDTO {

 int get id; String get name; String get balance; String get currency;
/// Create a copy of AccountBriefDTO
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountBriefDTOCopyWith<AccountBriefDTO> get copyWith => _$AccountBriefDTOCopyWithImpl<AccountBriefDTO>(this as AccountBriefDTO, _$identity);

  /// Serializes this AccountBriefDTO to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountBriefDTO&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,balance,currency);

@override
String toString() {
  return 'AccountBriefDTO(id: $id, name: $name, balance: $balance, currency: $currency)';
}


}

/// @nodoc
abstract mixin class $AccountBriefDTOCopyWith<$Res>  {
  factory $AccountBriefDTOCopyWith(AccountBriefDTO value, $Res Function(AccountBriefDTO) _then) = _$AccountBriefDTOCopyWithImpl;
@useResult
$Res call({
 int id, String name, String balance, String currency
});




}
/// @nodoc
class _$AccountBriefDTOCopyWithImpl<$Res>
    implements $AccountBriefDTOCopyWith<$Res> {
  _$AccountBriefDTOCopyWithImpl(this._self, this._then);

  final AccountBriefDTO _self;
  final $Res Function(AccountBriefDTO) _then;

/// Create a copy of AccountBriefDTO
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? balance = null,Object? currency = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _AccountBriefDTO implements AccountBriefDTO {
  const _AccountBriefDTO({required this.id, required this.name, required this.balance, required this.currency});
  factory _AccountBriefDTO.fromJson(Map<String, dynamic> json) => _$AccountBriefDTOFromJson(json);

@override final  int id;
@override final  String name;
@override final  String balance;
@override final  String currency;

/// Create a copy of AccountBriefDTO
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountBriefDTOCopyWith<_AccountBriefDTO> get copyWith => __$AccountBriefDTOCopyWithImpl<_AccountBriefDTO>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccountBriefDTOToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountBriefDTO&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,balance,currency);

@override
String toString() {
  return 'AccountBriefDTO(id: $id, name: $name, balance: $balance, currency: $currency)';
}


}

/// @nodoc
abstract mixin class _$AccountBriefDTOCopyWith<$Res> implements $AccountBriefDTOCopyWith<$Res> {
  factory _$AccountBriefDTOCopyWith(_AccountBriefDTO value, $Res Function(_AccountBriefDTO) _then) = __$AccountBriefDTOCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String balance, String currency
});




}
/// @nodoc
class __$AccountBriefDTOCopyWithImpl<$Res>
    implements _$AccountBriefDTOCopyWith<$Res> {
  __$AccountBriefDTOCopyWithImpl(this._self, this._then);

  final _AccountBriefDTO _self;
  final $Res Function(_AccountBriefDTO) _then;

/// Create a copy of AccountBriefDTO
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? balance = null,Object? currency = null,}) {
  return _then(_AccountBriefDTO(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
