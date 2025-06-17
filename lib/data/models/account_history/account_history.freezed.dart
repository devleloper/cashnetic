// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_history.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AccountHistoryDTO {

 int get id; int get accountId; String get changeType; AccountStateDTO? get previousState; AccountStateDTO get newState; String get changeTimestamp; String get createdAt;
/// Create a copy of AccountHistoryDTO
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountHistoryDTOCopyWith<AccountHistoryDTO> get copyWith => _$AccountHistoryDTOCopyWithImpl<AccountHistoryDTO>(this as AccountHistoryDTO, _$identity);

  /// Serializes this AccountHistoryDTO to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountHistoryDTO&&(identical(other.id, id) || other.id == id)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.changeType, changeType) || other.changeType == changeType)&&(identical(other.previousState, previousState) || other.previousState == previousState)&&(identical(other.newState, newState) || other.newState == newState)&&(identical(other.changeTimestamp, changeTimestamp) || other.changeTimestamp == changeTimestamp)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountId,changeType,previousState,newState,changeTimestamp,createdAt);

@override
String toString() {
  return 'AccountHistoryDTO(id: $id, accountId: $accountId, changeType: $changeType, previousState: $previousState, newState: $newState, changeTimestamp: $changeTimestamp, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AccountHistoryDTOCopyWith<$Res>  {
  factory $AccountHistoryDTOCopyWith(AccountHistoryDTO value, $Res Function(AccountHistoryDTO) _then) = _$AccountHistoryDTOCopyWithImpl;
@useResult
$Res call({
 int id, int accountId, String changeType, AccountStateDTO? previousState, AccountStateDTO newState, String changeTimestamp, String createdAt
});


$AccountStateDTOCopyWith<$Res>? get previousState;$AccountStateDTOCopyWith<$Res> get newState;

}
/// @nodoc
class _$AccountHistoryDTOCopyWithImpl<$Res>
    implements $AccountHistoryDTOCopyWith<$Res> {
  _$AccountHistoryDTOCopyWithImpl(this._self, this._then);

  final AccountHistoryDTO _self;
  final $Res Function(AccountHistoryDTO) _then;

/// Create a copy of AccountHistoryDTO
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? accountId = null,Object? changeType = null,Object? previousState = freezed,Object? newState = null,Object? changeTimestamp = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as int,changeType: null == changeType ? _self.changeType : changeType // ignore: cast_nullable_to_non_nullable
as String,previousState: freezed == previousState ? _self.previousState : previousState // ignore: cast_nullable_to_non_nullable
as AccountStateDTO?,newState: null == newState ? _self.newState : newState // ignore: cast_nullable_to_non_nullable
as AccountStateDTO,changeTimestamp: null == changeTimestamp ? _self.changeTimestamp : changeTimestamp // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of AccountHistoryDTO
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountStateDTOCopyWith<$Res>? get previousState {
    if (_self.previousState == null) {
    return null;
  }

  return $AccountStateDTOCopyWith<$Res>(_self.previousState!, (value) {
    return _then(_self.copyWith(previousState: value));
  });
}/// Create a copy of AccountHistoryDTO
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountStateDTOCopyWith<$Res> get newState {
  
  return $AccountStateDTOCopyWith<$Res>(_self.newState, (value) {
    return _then(_self.copyWith(newState: value));
  });
}
}


/// @nodoc
@JsonSerializable()

class _AccountHistoryDTO implements AccountHistoryDTO {
  const _AccountHistoryDTO({required this.id, required this.accountId, required this.changeType, required this.previousState, required this.newState, required this.changeTimestamp, required this.createdAt});
  factory _AccountHistoryDTO.fromJson(Map<String, dynamic> json) => _$AccountHistoryDTOFromJson(json);

@override final  int id;
@override final  int accountId;
@override final  String changeType;
@override final  AccountStateDTO? previousState;
@override final  AccountStateDTO newState;
@override final  String changeTimestamp;
@override final  String createdAt;

/// Create a copy of AccountHistoryDTO
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountHistoryDTOCopyWith<_AccountHistoryDTO> get copyWith => __$AccountHistoryDTOCopyWithImpl<_AccountHistoryDTO>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccountHistoryDTOToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountHistoryDTO&&(identical(other.id, id) || other.id == id)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.changeType, changeType) || other.changeType == changeType)&&(identical(other.previousState, previousState) || other.previousState == previousState)&&(identical(other.newState, newState) || other.newState == newState)&&(identical(other.changeTimestamp, changeTimestamp) || other.changeTimestamp == changeTimestamp)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountId,changeType,previousState,newState,changeTimestamp,createdAt);

@override
String toString() {
  return 'AccountHistoryDTO(id: $id, accountId: $accountId, changeType: $changeType, previousState: $previousState, newState: $newState, changeTimestamp: $changeTimestamp, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AccountHistoryDTOCopyWith<$Res> implements $AccountHistoryDTOCopyWith<$Res> {
  factory _$AccountHistoryDTOCopyWith(_AccountHistoryDTO value, $Res Function(_AccountHistoryDTO) _then) = __$AccountHistoryDTOCopyWithImpl;
@override @useResult
$Res call({
 int id, int accountId, String changeType, AccountStateDTO? previousState, AccountStateDTO newState, String changeTimestamp, String createdAt
});


@override $AccountStateDTOCopyWith<$Res>? get previousState;@override $AccountStateDTOCopyWith<$Res> get newState;

}
/// @nodoc
class __$AccountHistoryDTOCopyWithImpl<$Res>
    implements _$AccountHistoryDTOCopyWith<$Res> {
  __$AccountHistoryDTOCopyWithImpl(this._self, this._then);

  final _AccountHistoryDTO _self;
  final $Res Function(_AccountHistoryDTO) _then;

/// Create a copy of AccountHistoryDTO
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? accountId = null,Object? changeType = null,Object? previousState = freezed,Object? newState = null,Object? changeTimestamp = null,Object? createdAt = null,}) {
  return _then(_AccountHistoryDTO(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as int,changeType: null == changeType ? _self.changeType : changeType // ignore: cast_nullable_to_non_nullable
as String,previousState: freezed == previousState ? _self.previousState : previousState // ignore: cast_nullable_to_non_nullable
as AccountStateDTO?,newState: null == newState ? _self.newState : newState // ignore: cast_nullable_to_non_nullable
as AccountStateDTO,changeTimestamp: null == changeTimestamp ? _self.changeTimestamp : changeTimestamp // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of AccountHistoryDTO
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountStateDTOCopyWith<$Res>? get previousState {
    if (_self.previousState == null) {
    return null;
  }

  return $AccountStateDTOCopyWith<$Res>(_self.previousState!, (value) {
    return _then(_self.copyWith(previousState: value));
  });
}/// Create a copy of AccountHistoryDTO
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountStateDTOCopyWith<$Res> get newState {
  
  return $AccountStateDTOCopyWith<$Res>(_self.newState, (value) {
    return _then(_self.copyWith(newState: value));
  });
}
}

// dart format on
