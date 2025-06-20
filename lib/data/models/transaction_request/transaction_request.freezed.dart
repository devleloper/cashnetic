// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TransactionRequestDTO {

 int? get accountId; int? get categoryId; String? get amount; String? get transactionDate; String? get comment;
/// Create a copy of TransactionRequestDTO
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionRequestDTOCopyWith<TransactionRequestDTO> get copyWith => _$TransactionRequestDTOCopyWithImpl<TransactionRequestDTO>(this as TransactionRequestDTO, _$identity);

  /// Serializes this TransactionRequestDTO to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionRequestDTO&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.transactionDate, transactionDate) || other.transactionDate == transactionDate)&&(identical(other.comment, comment) || other.comment == comment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accountId,categoryId,amount,transactionDate,comment);

@override
String toString() {
  return 'TransactionRequestDTO(accountId: $accountId, categoryId: $categoryId, amount: $amount, transactionDate: $transactionDate, comment: $comment)';
}


}

/// @nodoc
abstract mixin class $TransactionRequestDTOCopyWith<$Res>  {
  factory $TransactionRequestDTOCopyWith(TransactionRequestDTO value, $Res Function(TransactionRequestDTO) _then) = _$TransactionRequestDTOCopyWithImpl;
@useResult
$Res call({
 int? accountId, int? categoryId, String? amount, String? transactionDate, String? comment
});




}
/// @nodoc
class _$TransactionRequestDTOCopyWithImpl<$Res>
    implements $TransactionRequestDTOCopyWith<$Res> {
  _$TransactionRequestDTOCopyWithImpl(this._self, this._then);

  final TransactionRequestDTO _self;
  final $Res Function(TransactionRequestDTO) _then;

/// Create a copy of TransactionRequestDTO
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accountId = freezed,Object? categoryId = freezed,Object? amount = freezed,Object? transactionDate = freezed,Object? comment = freezed,}) {
  return _then(_self.copyWith(
accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as int?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int?,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String?,transactionDate: freezed == transactionDate ? _self.transactionDate : transactionDate // ignore: cast_nullable_to_non_nullable
as String?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _TransactionRequestDTO implements TransactionRequestDTO {
  const _TransactionRequestDTO({required this.accountId, required this.categoryId, required this.amount, required this.transactionDate, required this.comment});
  factory _TransactionRequestDTO.fromJson(Map<String, dynamic> json) => _$TransactionRequestDTOFromJson(json);

@override final  int? accountId;
@override final  int? categoryId;
@override final  String? amount;
@override final  String? transactionDate;
@override final  String? comment;

/// Create a copy of TransactionRequestDTO
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionRequestDTOCopyWith<_TransactionRequestDTO> get copyWith => __$TransactionRequestDTOCopyWithImpl<_TransactionRequestDTO>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionRequestDTOToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionRequestDTO&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.transactionDate, transactionDate) || other.transactionDate == transactionDate)&&(identical(other.comment, comment) || other.comment == comment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accountId,categoryId,amount,transactionDate,comment);

@override
String toString() {
  return 'TransactionRequestDTO(accountId: $accountId, categoryId: $categoryId, amount: $amount, transactionDate: $transactionDate, comment: $comment)';
}


}

/// @nodoc
abstract mixin class _$TransactionRequestDTOCopyWith<$Res> implements $TransactionRequestDTOCopyWith<$Res> {
  factory _$TransactionRequestDTOCopyWith(_TransactionRequestDTO value, $Res Function(_TransactionRequestDTO) _then) = __$TransactionRequestDTOCopyWithImpl;
@override @useResult
$Res call({
 int? accountId, int? categoryId, String? amount, String? transactionDate, String? comment
});




}
/// @nodoc
class __$TransactionRequestDTOCopyWithImpl<$Res>
    implements _$TransactionRequestDTOCopyWith<$Res> {
  __$TransactionRequestDTOCopyWithImpl(this._self, this._then);

  final _TransactionRequestDTO _self;
  final $Res Function(_TransactionRequestDTO) _then;

/// Create a copy of TransactionRequestDTO
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accountId = freezed,Object? categoryId = freezed,Object? amount = freezed,Object? transactionDate = freezed,Object? comment = freezed,}) {
  return _then(_TransactionRequestDTO(
accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as int?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int?,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String?,transactionDate: freezed == transactionDate ? _self.transactionDate : transactionDate // ignore: cast_nullable_to_non_nullable
as String?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
