// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TransactionDTO {

 int get id; int get accountId; int get categoryId; String get amount; String get transactionDate; String? get comment; String get createdAt; String get updatedAt;
/// Create a copy of TransactionDTO
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionDTOCopyWith<TransactionDTO> get copyWith => _$TransactionDTOCopyWithImpl<TransactionDTO>(this as TransactionDTO, _$identity);

  /// Serializes this TransactionDTO to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionDTO&&(identical(other.id, id) || other.id == id)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.transactionDate, transactionDate) || other.transactionDate == transactionDate)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountId,categoryId,amount,transactionDate,comment,createdAt,updatedAt);

@override
String toString() {
  return 'TransactionDTO(id: $id, accountId: $accountId, categoryId: $categoryId, amount: $amount, transactionDate: $transactionDate, comment: $comment, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $TransactionDTOCopyWith<$Res>  {
  factory $TransactionDTOCopyWith(TransactionDTO value, $Res Function(TransactionDTO) _then) = _$TransactionDTOCopyWithImpl;
@useResult
$Res call({
 int id, int accountId, int categoryId, String amount, String transactionDate, String? comment, String createdAt, String updatedAt
});




}
/// @nodoc
class _$TransactionDTOCopyWithImpl<$Res>
    implements $TransactionDTOCopyWith<$Res> {
  _$TransactionDTOCopyWithImpl(this._self, this._then);

  final TransactionDTO _self;
  final $Res Function(TransactionDTO) _then;

/// Create a copy of TransactionDTO
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? accountId = null,Object? categoryId = null,Object? amount = null,Object? transactionDate = null,Object? comment = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as int,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,transactionDate: null == transactionDate ? _self.transactionDate : transactionDate // ignore: cast_nullable_to_non_nullable
as String,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _TransactionDTO implements TransactionDTO {
  const _TransactionDTO({required this.id, required this.accountId, required this.categoryId, required this.amount, required this.transactionDate, required this.comment, required this.createdAt, required this.updatedAt});
  factory _TransactionDTO.fromJson(Map<String, dynamic> json) => _$TransactionDTOFromJson(json);

@override final  int id;
@override final  int accountId;
@override final  int categoryId;
@override final  String amount;
@override final  String transactionDate;
@override final  String? comment;
@override final  String createdAt;
@override final  String updatedAt;

/// Create a copy of TransactionDTO
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionDTOCopyWith<_TransactionDTO> get copyWith => __$TransactionDTOCopyWithImpl<_TransactionDTO>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionDTOToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionDTO&&(identical(other.id, id) || other.id == id)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.transactionDate, transactionDate) || other.transactionDate == transactionDate)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountId,categoryId,amount,transactionDate,comment,createdAt,updatedAt);

@override
String toString() {
  return 'TransactionDTO(id: $id, accountId: $accountId, categoryId: $categoryId, amount: $amount, transactionDate: $transactionDate, comment: $comment, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$TransactionDTOCopyWith<$Res> implements $TransactionDTOCopyWith<$Res> {
  factory _$TransactionDTOCopyWith(_TransactionDTO value, $Res Function(_TransactionDTO) _then) = __$TransactionDTOCopyWithImpl;
@override @useResult
$Res call({
 int id, int accountId, int categoryId, String amount, String transactionDate, String? comment, String createdAt, String updatedAt
});




}
/// @nodoc
class __$TransactionDTOCopyWithImpl<$Res>
    implements _$TransactionDTOCopyWith<$Res> {
  __$TransactionDTOCopyWithImpl(this._self, this._then);

  final _TransactionDTO _self;
  final $Res Function(_TransactionDTO) _then;

/// Create a copy of TransactionDTO
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? accountId = null,Object? categoryId = null,Object? amount = null,Object? transactionDate = null,Object? comment = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_TransactionDTO(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as int,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,transactionDate: null == transactionDate ? _self.transactionDate : transactionDate // ignore: cast_nullable_to_non_nullable
as String,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
