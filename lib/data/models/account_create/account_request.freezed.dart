// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AccountRequestDTO {

 String? get name; String? get balance; String? get currency;
/// Create a copy of AccountRequestDTO
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountRequestDTOCopyWith<AccountRequestDTO> get copyWith => _$AccountRequestDTOCopyWithImpl<AccountRequestDTO>(this as AccountRequestDTO, _$identity);

  /// Serializes this AccountRequestDTO to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountRequestDTO&&(identical(other.name, name) || other.name == name)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,balance,currency);

@override
String toString() {
  return 'AccountRequestDTO(name: $name, balance: $balance, currency: $currency)';
}


}

/// @nodoc
abstract mixin class $AccountRequestDTOCopyWith<$Res>  {
  factory $AccountRequestDTOCopyWith(AccountRequestDTO value, $Res Function(AccountRequestDTO) _then) = _$AccountRequestDTOCopyWithImpl;
@useResult
$Res call({
 String? name, String? balance, String? currency
});




}
/// @nodoc
class _$AccountRequestDTOCopyWithImpl<$Res>
    implements $AccountRequestDTOCopyWith<$Res> {
  _$AccountRequestDTOCopyWithImpl(this._self, this._then);

  final AccountRequestDTO _self;
  final $Res Function(AccountRequestDTO) _then;

/// Create a copy of AccountRequestDTO
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? balance = freezed,Object? currency = freezed,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,balance: freezed == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as String?,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _AccountRequestDTO implements AccountRequestDTO {
  const _AccountRequestDTO({required this.name, required this.balance, required this.currency});
  factory _AccountRequestDTO.fromJson(Map<String, dynamic> json) => _$AccountRequestDTOFromJson(json);

@override final  String? name;
@override final  String? balance;
@override final  String? currency;

/// Create a copy of AccountRequestDTO
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountRequestDTOCopyWith<_AccountRequestDTO> get copyWith => __$AccountRequestDTOCopyWithImpl<_AccountRequestDTO>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccountRequestDTOToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountRequestDTO&&(identical(other.name, name) || other.name == name)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,balance,currency);

@override
String toString() {
  return 'AccountRequestDTO(name: $name, balance: $balance, currency: $currency)';
}


}

/// @nodoc
abstract mixin class _$AccountRequestDTOCopyWith<$Res> implements $AccountRequestDTOCopyWith<$Res> {
  factory _$AccountRequestDTOCopyWith(_AccountRequestDTO value, $Res Function(_AccountRequestDTO) _then) = __$AccountRequestDTOCopyWithImpl;
@override @useResult
$Res call({
 String? name, String? balance, String? currency
});




}
/// @nodoc
class __$AccountRequestDTOCopyWithImpl<$Res>
    implements _$AccountRequestDTOCopyWith<$Res> {
  __$AccountRequestDTOCopyWithImpl(this._self, this._then);

  final _AccountRequestDTO _self;
  final $Res Function(_AccountRequestDTO) _then;

/// Create a copy of AccountRequestDTO
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? balance = freezed,Object? currency = freezed,}) {
  return _then(_AccountRequestDTO(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,balance: freezed == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as String?,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
