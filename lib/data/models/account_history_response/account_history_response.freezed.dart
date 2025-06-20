// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_history_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AccountHistoryResponseDTO {

 int get accountId; String get accountName; String get currency; String get currentBalance; List<AccountHistoryDTO> get history;
/// Create a copy of AccountHistoryResponseDTO
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountHistoryResponseDTOCopyWith<AccountHistoryResponseDTO> get copyWith => _$AccountHistoryResponseDTOCopyWithImpl<AccountHistoryResponseDTO>(this as AccountHistoryResponseDTO, _$identity);

  /// Serializes this AccountHistoryResponseDTO to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountHistoryResponseDTO&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.currentBalance, currentBalance) || other.currentBalance == currentBalance)&&const DeepCollectionEquality().equals(other.history, history));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accountId,accountName,currency,currentBalance,const DeepCollectionEquality().hash(history));

@override
String toString() {
  return 'AccountHistoryResponseDTO(accountId: $accountId, accountName: $accountName, currency: $currency, currentBalance: $currentBalance, history: $history)';
}


}

/// @nodoc
abstract mixin class $AccountHistoryResponseDTOCopyWith<$Res>  {
  factory $AccountHistoryResponseDTOCopyWith(AccountHistoryResponseDTO value, $Res Function(AccountHistoryResponseDTO) _then) = _$AccountHistoryResponseDTOCopyWithImpl;
@useResult
$Res call({
 int accountId, String accountName, String currency, String currentBalance, List<AccountHistoryDTO> history
});




}
/// @nodoc
class _$AccountHistoryResponseDTOCopyWithImpl<$Res>
    implements $AccountHistoryResponseDTOCopyWith<$Res> {
  _$AccountHistoryResponseDTOCopyWithImpl(this._self, this._then);

  final AccountHistoryResponseDTO _self;
  final $Res Function(AccountHistoryResponseDTO) _then;

/// Create a copy of AccountHistoryResponseDTO
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accountId = null,Object? accountName = null,Object? currency = null,Object? currentBalance = null,Object? history = null,}) {
  return _then(_self.copyWith(
accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as int,accountName: null == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,currentBalance: null == currentBalance ? _self.currentBalance : currentBalance // ignore: cast_nullable_to_non_nullable
as String,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<AccountHistoryDTO>,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _AccountHistoryResponseDTO implements AccountHistoryResponseDTO {
  const _AccountHistoryResponseDTO({required this.accountId, required this.accountName, required this.currency, required this.currentBalance, required final  List<AccountHistoryDTO> history}): _history = history;
  factory _AccountHistoryResponseDTO.fromJson(Map<String, dynamic> json) => _$AccountHistoryResponseDTOFromJson(json);

@override final  int accountId;
@override final  String accountName;
@override final  String currency;
@override final  String currentBalance;
 final  List<AccountHistoryDTO> _history;
@override List<AccountHistoryDTO> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}


/// Create a copy of AccountHistoryResponseDTO
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountHistoryResponseDTOCopyWith<_AccountHistoryResponseDTO> get copyWith => __$AccountHistoryResponseDTOCopyWithImpl<_AccountHistoryResponseDTO>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccountHistoryResponseDTOToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountHistoryResponseDTO&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.currentBalance, currentBalance) || other.currentBalance == currentBalance)&&const DeepCollectionEquality().equals(other._history, _history));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accountId,accountName,currency,currentBalance,const DeepCollectionEquality().hash(_history));

@override
String toString() {
  return 'AccountHistoryResponseDTO(accountId: $accountId, accountName: $accountName, currency: $currency, currentBalance: $currentBalance, history: $history)';
}


}

/// @nodoc
abstract mixin class _$AccountHistoryResponseDTOCopyWith<$Res> implements $AccountHistoryResponseDTOCopyWith<$Res> {
  factory _$AccountHistoryResponseDTOCopyWith(_AccountHistoryResponseDTO value, $Res Function(_AccountHistoryResponseDTO) _then) = __$AccountHistoryResponseDTOCopyWithImpl;
@override @useResult
$Res call({
 int accountId, String accountName, String currency, String currentBalance, List<AccountHistoryDTO> history
});




}
/// @nodoc
class __$AccountHistoryResponseDTOCopyWithImpl<$Res>
    implements _$AccountHistoryResponseDTOCopyWith<$Res> {
  __$AccountHistoryResponseDTOCopyWithImpl(this._self, this._then);

  final _AccountHistoryResponseDTO _self;
  final $Res Function(_AccountHistoryResponseDTO) _then;

/// Create a copy of AccountHistoryResponseDTO
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accountId = null,Object? accountName = null,Object? currency = null,Object? currentBalance = null,Object? history = null,}) {
  return _then(_AccountHistoryResponseDTO(
accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as int,accountName: null == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,currentBalance: null == currentBalance ? _self.currentBalance : currentBalance // ignore: cast_nullable_to_non_nullable
as String,history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<AccountHistoryDTO>,
  ));
}


}

// dart format on
