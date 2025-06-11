import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart';

enum TransactionType { income, expense }

@freezed
abstract class TransactionModel with _$TransactionModel {
  const factory TransactionModel({
    required int id,
    required String account,
    required String categoryIcon,
    required String categoryTitle,
    required TransactionType type,
    String? comment,
    required double amount,
    required DateTime dateTime,
  }) = _TransactionModel;

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);
}
