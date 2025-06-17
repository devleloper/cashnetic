// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AccountStateDTO {

 int get id; String get name; String get balance; String get currency;
/// Create a copy of AccountStateDTO
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountStateDTOCopyWith<AccountStateDTO> get copyWith => _$AccountStateDTOCopyWithImpl<AccountStateDTO>(this as AccountStateDTO, _$identity);

  /// Serializes this AccountStateDTO to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountStateDTO&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,balance,currency);

@override
String toString() {
  return 'AccountStateDTO(id: $id, name: $name, balance: $balance, currency: $currency)';
}


}

/// @nodoc
abstract mixin class $AccountStateDTOCopyWith<$Res>  {
  factory $AccountStateDTOCopyWith(AccountStateDTO value, $Res Function(AccountStateDTO) _then) = _$AccountStateDTOCopyWithImpl;
@useResult
$Res call({
 int id, String name, String balance, String currency
});




}
/// @nodoc
class _$AccountStateDTOCopyWithImpl<$Res>
    implements $AccountStateDTOCopyWith<$Res> {
  _$AccountStateDTOCopyWithImpl(this._self, this._then);

  final AccountStateDTO _self;
  final $Res Function(AccountStateDTO) _then;

/// Create a copy of AccountStateDTO
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

class _AccountStateDTO implements AccountStateDTO {
  const _AccountStateDTO({required this.id, required this.name, required this.balance, required this.currency});
  factory _AccountStateDTO.fromJson(Map<String, dynamic> json) => _$AccountStateDTOFromJson(json);

@override final  int id;
@override final  String name;
@override final  String balance;
@override final  String currency;

/// Create a copy of AccountStateDTO
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountStateDTOCopyWith<_AccountStateDTO> get copyWith => __$AccountStateDTOCopyWithImpl<_AccountStateDTO>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccountStateDTOToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountStateDTO&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,balance,currency);

@override
String toString() {
  return 'AccountStateDTO(id: $id, name: $name, balance: $balance, currency: $currency)';
}


}

/// @nodoc
abstract mixin class _$AccountStateDTOCopyWith<$Res> implements $AccountStateDTOCopyWith<$Res> {
  factory _$AccountStateDTOCopyWith(_AccountStateDTO value, $Res Function(_AccountStateDTO) _then) = __$AccountStateDTOCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String balance, String currency
});




}
/// @nodoc
class __$AccountStateDTOCopyWithImpl<$Res>
    implements _$AccountStateDTOCopyWith<$Res> {
  __$AccountStateDTOCopyWithImpl(this._self, this._then);

  final _AccountStateDTO _self;
  final $Res Function(_AccountStateDTO) _then;

/// Create a copy of AccountStateDTO
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? balance = null,Object? currency = null,}) {
  return _then(_AccountStateDTO(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
